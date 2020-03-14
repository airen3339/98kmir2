unit Misc;

interface

uses
  Windows, Messages, SysUtils, WinSock2, ClientSession;

function EncodeString(Str: string): string;
function DecodeString(Str: string): string;
function EncodeBuf(Buf, Len, DstBuf: Integer): Integer;
function DecodeBuf(Buf, Len, DstBuf: Integer): Integer;

procedure CloseIPConnect(const nRemoteIP: Integer);
function KickUser(const nRemoteIP: Integer): Boolean; overload;
procedure KickUser(const UserObj: TSessionObj); overload;
procedure BlockUser(const UserObj: TSessionObj);

function ReverseIP(dwIP: DWORD): DWORD;
function AnsiStrToVal(const nPtr: PChar; var nPos: Integer): Integer;

procedure SendGameCenterMsg(wIdent: Word; sSendMsg: string);

function CheckAccountName(sName: string): Boolean;

implementation

uses
  AcceptExWorkedThread, SHSocket, AppMain, Protocol,
  ConfigManager, IPAddrFilter, Grobal2, SDK;

function EncodeString(Str: string): string;
var
  EncBuf: array[0..32 * 1024 - 1] of Char;
begin
  EncodeBuf(Integer(PChar(Str)), Length(Str), Integer(@EncBuf));
  Result := StrPas(EncBuf);
end;

function DecodeString(Str: string): string;
var
  EncBuf: array[0..32 * 1024 - 1] of Char;
begin
  DecodeBuf(Integer(PChar(Str)), Length(Str), Integer(@EncBuf));
  Result := StrPas(EncBuf);
end;

function EncodeBuf(Buf, Len, DstBuf: Integer): Integer;
var
  no, i: Integer;
  temp, remainder, c, bySeed, byBase: Byte;
  RPos: Integer;
begin
  no := 2;
  remainder := 0;
  RPos := DstBuf;

  bySeed := $AC;
  byBase := $3C;

  for i := 0 to Len - 1 do
  begin
    c := pbyte(Buf)^ xor bySeed;
    inc(Buf);
    if no = 6 then
    begin
      PChar(DstBuf)^ := Chr((c and $3F) + byBase);
      inc(DstBuf);
      remainder := remainder or ((c shr 2) and $30);
      PChar(DstBuf)^ := Chr(remainder + byBase);
      inc(DstBuf);
      remainder := 0;
    end
    else
    begin
      temp := c shr 2;
      PChar(DstBuf)^ := Chr(((temp and $3C) or (c and $3)) + byBase);
      inc(DstBuf);
      remainder := (remainder shl 2) or (temp and $3);
    end;
    no := no mod 6 + 2;
  end;
  if no <> 2 then
  begin
    PChar(DstBuf)^ := Chr(remainder + byBase);
    inc(DstBuf);
  end;
  Result := DstBuf - RPos;
  PChar(DstBuf)^ := #0;
end;

function DecodeBuf(Buf, Len, DstBuf: Integer): Integer;
var
  nCycles, nBytesLeft, i, CurCycleBegin: Integer;
  temp, remainder, c, bySeed, byBase: Byte;
  RPos: Integer;
begin
  RPos := DstBuf;
  nCycles := Len div 4;
  nBytesLeft := Len mod 4;

  bySeed := $AC;
  byBase := $3C;

  for i := 0 to nCycles - 1 do
  begin
    CurCycleBegin := i * 4;
    remainder := pbyte(Buf + CurCycleBegin + 3)^ - byBase;

    temp := pbyte(Buf + CurCycleBegin)^ - byBase;
    c := ((temp shl 2) and $F0) or (remainder and $0C) or (temp and $3);

    PChar(DstBuf)^ := Chr(c xor bySeed);
    inc(DstBuf);

    temp := pbyte(Buf + CurCycleBegin + 1)^ - byBase;

    c := ((temp shl 2) and $F0) or ((remainder shl 2) and $0C) or (temp and $3);

    PChar(DstBuf)^ := Chr(c xor bySeed);
    inc(DstBuf);

    temp := pbyte(Buf + CurCycleBegin + 2)^ - byBase;
    c := temp or ((remainder shl 2) and $C0);

    PChar(DstBuf)^ := Chr(c xor bySeed);
    inc(DstBuf);
  end;
  if nBytesLeft = 2 then
  begin
    remainder := pbyte(Buf + Len - 1)^ - byBase;
    temp := pbyte(Buf + Len - 2)^ - byBase;
    c := ((temp shl 2) and $F0) or ((remainder shl 2) and $0C) or (temp and $3);
    PChar(DstBuf)^ := Chr(c xor bySeed);
    inc(DstBuf);
  end
  else if nBytesLeft = 3 then
  begin
    remainder := pbyte(Buf + Len - 1)^ - byBase;
    temp := pbyte(Buf + Len - 3)^ - byBase;
    c := ((temp shl 2) and $F0) or (remainder and $0C) or (temp and $3);
    PChar(DstBuf)^ := Chr(c xor bySeed);
    inc(DstBuf);

    temp := pbyte(Buf + Len - 2)^ - byBase;
    c := ((temp shl 2) and $F0) or ((remainder shl 2) and $0C) or (temp and $3);
    PChar(DstBuf)^ := Chr(c xor bySeed);
    inc(DstBuf);
  end;
  Result := DstBuf - RPos;
  PChar(DstBuf)^ := #0;
end;

procedure CloseIPConnect(const nRemoteIP: Integer);
var
  i, n: Integer;
  UserObj: TSessionObj;
begin
  if not g_fServiceStarted then
    Exit;
  for n := 0 to USER_ARRAY_COUNT - 1 do
  begin
    UserObj := g_UserList[n];
    if (UserObj <> nil) and
      (UserObj.m_tLastGameSvr <> nil) and
      (UserObj.m_tLastGameSvr.Active) and
      (UserObj.m_pUserOBJ.nIPAddr = nRemoteIP) then
    begin
      if UserObj.m_fHandleLogin >= 2 then
      begin
        UserObj.SendDefMessage(SM_OUTOFCONNECTION, UserObj.m_nSvrObject, 0, 0, 0, '');
        UserObj.m_fKickFlag := True;
      end
      else
        SHSocket.FreeSocket(UserObj.m_pUserOBJ._SendObj.Socket);
    end;
  end;
end;

function KickUser(const nRemoteIP: Integer): Boolean;
begin
  Result := True;
  if g_pConfig.m_fKickOverPacketSize then
  begin
    case g_pConfig.m_tBlockIPMethod of
      mDisconnect:
        begin
          Result := False;
        end;
      mBlock:
        begin
          AddToTempBlockIPList(nRemoteIP);
          CloseIPConnect(nRemoteIP);
          Result := False;
        end;
      mBlockList:
        begin
          AddToBlockIPList(nRemoteIP);
          CloseIPConnect(nRemoteIP);
          Result := False;
        end;
    end;
  end;
end;

procedure KickUser(const UserObj: TSessionObj);
begin
  if g_pConfig.m_fKickOverPacketSize then
  begin
    SHSocket.FreeSocket(UserObj.m_pUserOBJ._SendObj.Socket);
    UserObj.m_fKickFlag := True;
    case g_pConfig.m_tBlockIPMethod of
      mBlock:
        begin
          AddToTempBlockIPList(UserObj.m_pUserOBJ.nIPAddr);
        end;
      mBlockList:
        begin
          AddToBlockIPList(UserObj.m_pUserOBJ.nIPAddr);
        end;
    end;
  end;
end;

procedure BlockUser(const UserObj: TSessionObj);
begin
  if g_pConfig.m_fKickOverPacketSize then
  begin
    UserObj.m_fKickFlag := True;
    case g_pConfig.m_tBlockIPMethod of
      mBlock:
        begin
          AddToTempBlockIPList(UserObj.m_pUserOBJ.nIPAddr);
        end;
      mBlockList:
        begin
          AddToBlockIPList(UserObj.m_pUserOBJ.nIPAddr);
        end;
    end;
  end;
end;

function ReverseIP(dwIP: DWORD): DWORD;
begin
  Result := (LOBYTE(LOWORD(dwIP)) shl 24) or
    (HIBYTE(LOWORD(dwIP)) shl 16) or
    (LOBYTE(HIWORD(dwIP)) shl 8) or
    (HIBYTE(HIWORD(dwIP)));
end;

function AnsiStrToVal(const nPtr: PChar; var nPos: Integer): Integer;
var
  c: Char;
  tPtr: PChar;
  total: Integer;
begin
  nPos := 0;
  Result := 0;
  if nPtr = nil then
    Exit;
  tPtr := nPtr;
  c := tPtr^;
  total := 0;
  while ((c >= '0') and (c <= '9')) do
  begin
    total := 10 * total + (Byte(c) - Byte('0'));
    inc(tPtr);
    inc(nPos);
    c := tPtr^;
  end;
  Result := total;
end;

procedure SendGameCenterMsg(wIdent: Word; sSendMsg: string);
var
  SendData: TCopyDataStruct;
  nParam: Integer;
begin
  nParam := MakeLong(Word(tSelGate), wIdent);
  SendData.cbData := Length(sSendMsg) + 1;
  GetMem(SendData.lpData, SendData.cbData);
  StrCopy(SendData.lpData, PChar(sSendMsg));
  SendMessage(g_hGameCenterHandle, WM_COPYDATA, nParam, Cardinal(@SendData));
  FreeMem(SendData.lpData);
end;

function CheckAccountName(sName: string): Boolean;
var
  I: Integer;
  nLen: Integer;
begin
  Result := False;
  if sName = '' then
    Exit;
  Result := true;
  nLen := Length(sName);
  I := 1;
  while (true) do
  begin
    if I > nLen then
      Break;
    if (sName[I] < '0') or (sName[I] > 'z') then
    begin
      Result := False;
      if (sName[I] >= #$B0) and (sName[I] <= #$C8) then
      begin
        Inc(I);
        if I <= nLen then
          if (sName[I] >= #$A1) and (sName[I] <= #$FE) then
            Result := true;
      end;
      if not Result then
        Break;
    end;
    Inc(I);
  end;
end;

end.
