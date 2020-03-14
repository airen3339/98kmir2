unit TableDef;

interface

uses
  Windows, Messages, SysUtils;

type
  TMagDelayList = array[0..127] of Integer;

var
  MAIGIC_DELAY_ARRAY: array[0..127] of BOOL = (True,
    True, True, True, True, True, True, False, True, True, True, True, False, //1~12
    True, True, True, True, True, True, True, True, True, True, True, True, //13~24
    False, False, False, True, True, True, True, True, True, True, False, True, //25~36
    True, True, True, False, False, False, False, True, True, True, True, True, //37~48
    True, True, True, True, True, True, False, False, True, True, False, False, //49~60
    False, False, False, False, False, False, True, True, True, True, True, True, //61~72
    True, True, True, True, True, True, True, True, True, True, True, True, //73~84
    True, True, True, True, True, True, True, True, True, True, True, True, //85~96
    True, True, True, //97~99
    True, True, True, True, True, True, True, True, True, True, True, True, //100..111
    True, True, False, False, True, True, False, False, False, //112~119
    False, False, False, False, False, False, False); //120~128

  MAIGIC_ATTACK_ARRAY: array[0..127] of BOOL = (
    False,
    True, //С����
    False, //������
    False, //��������
    False, //������ս��
    True, //�����
    True, //ʩ����
    False, False,
    True, //��������
    True, //�����׹�
    True, //�׵���
    False, //12
    True, //������
    False, False, False, False, False, False, False, False,
    True, //��ǽ
    True, //���ѻ���
    True, //�����׹�
    False, False, False, False, False, False, False,
    True, //ʥ����
    True, //������
    False, False,
    True, //�����
    True, //ʨ�Ӻ� - Ⱥ���׵���
    True, //Ⱥ��ʩ����
    True, //���ض�
    False, //40
    True, //ʨ�Ӻ�
    False,
    False,
    True, //������
    True, //�����
    False,
    True, //��������
    False, //37~48
    False, //������
    False, //�޼�����
    True, //51
    True, //52
    True, //53
    True, //54
    False, //55
    False, //���ս���
    True, //��Ѫ��
    True, //���ǻ���
    False, //59
    False, //60
    False, //61
    False, //62
    False, //63
    False, //64
    False, //65
    False, //66
    False, //67
    False,
    False,
    False,
    True, //71������
    True, True, True, True, True, True, True, True, True, True, True, True,
    True, True, True, True, True, True, True, True, True, True, True, True, //84~95
    True, True, True, True, //96..99
    True, True, True, True, True, True, True, True, True, True, True, True, //100~111
    True, True, True, True, True, True, True, True, //112
    True, True, True, True, True, True, True, True); //120~128

  //ħ�����ӳٱ�
  MAIGIC_DELAY_TIME_LIST_DEF: TMagDelayList;
  MAIGIC_DELAY_TIME_LIST: TMagDelayList = (
    60000,
    {01} 1110 + 60, //С����
    {02} 1110 + 40, //������
    {03} 1110, //��������
    {04} 1110, //����ս��
    {05} 1110 + 60, //�����
    {06} 1110 + 40, //ʩ����
    {07} 1110, //��ɱ����
    {08} 1110 + 30, //���ܻ�
    {09} 1110 + 60, //������
    {10} 1110 + 100, //�����Ӱ
    {11} 1110 + 100, //�׵���
    {12} 1110, //��ɱ����
    {13} 1110 + 60, //�����
    {14} 1110 + 40, //�����
    {15} 1110 + 40, //��ʥս����
    {16} 1110 + 50, //��ħ��
    {17} 1110 + 50, //�ٻ�����
    {18} 1110 + 50, //������
    {19} 1110 + 50, //����������
    {20} 1110 + 60, //�ջ�֮��
    {21} 1110 + 50, //˲Ϣ�ƶ�
    {22} 1110 + 120, //��ǽ
    {23} 1110 + 60, //���ѻ���
    {24} 1110 + 60, //�����׹�
    {25} 1110, //�����䵶
    {26} 1110, //�һ𽣷�
    {27} 1110, //Ұ����ײ
    {28} 1110 + 40, //������ʾ
    {29} 1110 + 40, //Ⱥ��������
    {30} 1110 + 120, //�ٻ�����
    {31} 1110, //ħ����
    {32} 1320 - 90, //ʥ����
    {33} 1260 - 90, //������
    {34} 1240 - 90, //�ⶾ��
    {35} 1260 - 90, //��ʨ�Ӻ�
    {36} 1260 - 90, //�����
    {37} 1320 - 90, //Ⱥ���׵���
    {38} 1320 - 90, //Ⱥ��ʩ����
    {39} 1320 - 90, //���ض�
    {40} 1110, //˫��ն
    {41} 1230 - 90, //ʨ�Ӻ�
    {42} 1110, //��Ӱ����
    {43} 1110, //��������
    {44} 1260 - 90, //������
    {45} 1260 - 90, //�����
    {46} 1260 - 90, //�ٻ�Ӣ��
    {47} 1260 - 90, //��������
    {48} 1230 - 90, //������
    {49} 1240 - 90, //������
    {50} 1230 - 90, //�޼�����
    {51} 1240 - 90, //쫷���
    {52} 1240 - 90, //������
    {53} 1240 - 90, //Ѫ��
    {54} 1260 - 90, //������
    {55} 1260 - 90, //
    {56} 1110, //���ս���
    {57} 1260 - 90, //��Ѫ��
    {58} 1320 - 90, //���ǻ���
    {59} 1300, //
    {60} 200, //�ƻ�ն
    {61} 200, //����ն
    {62} 200, //����һ��
    {63} 200, //�ɻ�����
    {64} 200, //ĩ������
    {65} 200, //��������
    {66} 1500 - 90, //Ӣ�ۿ���ն
    {67} 1800 - 90, //
    {68} 1110, //
    {69} 1110, //
    {70} 1700 - 90, //�����ٻ�
    {71} 1800 - 90, //Ӣ��������
    {72} 1110, //
    {73} 1110, //
    {74} 100, //Ӣ�۷�����
    {75} 100, //Ӣ�ۻ������
    {76} 100, //
    {77} 100, //
    {78} 100, //
    {79} 100, //
    {80} 100, //
    {81} 100, //
    {82} 100, //
    {83} 100, //
    {84} 100, //
    {85} 100, //
    {86} 100, //
    {87} 100, //
    100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100,
    350, 350, 350, 350, 350, 350, 350, 350, 350, 350, 350, 350, //100~111
    1300, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100);

  MAIGIC_NAME_LIST: array[0..127] of string = (
    '',
    '������',
    '������',
    '��������',
    '������ս��',
    '�����',
    'ʩ����',
    '��ɱ����',
    '���ܻ�',
    '������',
    '�����Ӱ',
    '�׵���',
    '��ɱ����',
    '�����',
    '�����',
    '��ʥս����',
    '��ħ��',
    '�ٻ�����',
    '������',
    '����������',
    '�ջ�֮��',
    '˲Ϣ�ƶ�',
    '��ǽ',
    '���ѻ���',
    '�����׹�',
    '�����䵶',
    '�һ𽣷�',
    'Ұ����ײ',
    '������ʾ',
    'Ⱥ��������',
    '�ٻ�����',
    'ħ����',
    'ʥ����',
    '������',
    '�ⶾ��',
    '��ʨ�Ӻ�',
    '�����',
    'Ⱥ���׵���',
    'Ⱥ��ʩ����',
    '���ض�',
    '˫��ն',
    'ʨ�Ӻ�',
    '��Ӱ����',
    '��������',
    '������',
    '�����',
    '�ٻ�Ӣ��',
    '��������',
    '������',
    '������',
    '�޼�����',
    '쫷���',
    '������',
    'Ѫ��',
    '������',
    '',
    '���ս���',
    '��Ѫ��',
    '���ǻ���',
    '',
    '�ƻ�ն',
    '����ն',
    '����һ��',
    '�ɻ�����',
    'ĩ������',
    '��������',
    '����ն', //66
    '���ؽ��', //67
    'Ψ�Ҷ���', //68
    '',
    'Ӣ�۳���',
    '������', //71
    '',
    '',
    '',
    '�������',
    '',
    '',
    '', //78
    '',
    '',
    '', //81
    '',
    '', //83
    '', //84
    '',
    '',
    '', //87
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '', //99
    '׷�Ĵ�',
    '����ɱ',
    '����ն',
    '��ɨǧ��',
    '�����',
    '���ױ�',
    '����ѩ��',
    '˫����',
    '��Х��',
    '������',
    '������',
    '�������',
    '��ת�����',
    '�Ͽ�ն',
    '����ٵ�',
    'Ѫ��һ��(ս)',
    'Ѫ��һ��(��)',
    'Ѫ��һ��(��)',
    '', '', '', '',
    '', '', '', '', '', '');

implementation

initialization
  MAIGIC_DELAY_TIME_LIST_DEF := MAIGIC_DELAY_TIME_LIST;

finalization

end.
