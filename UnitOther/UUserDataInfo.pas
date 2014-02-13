unit UUserDataInfo;

interface

uses Generics.Collections;

type

    // �ļ���Ŀ�����ļ�����
  TMaxBackupCountInfo = class
  public
    TypeName : string;
    FileCount : Integer;
  public
    constructor Create( _TypeName : string );
  end;
  TMaxBackupCountList = class( TObjectList<TMaxBackupCountInfo> )end;

    // �ļ��ռ������ļ�����
  TMaxBackupSizeInfo = class
  public
    TypeName : string;
    FileSize : Int64;
  public
    constructor Create( _TypeName : string );
  end;
  TMaxBackupSizeList = class( TObjectList<TMaxBackupSizeInfo> )end;

    // ·����ͳ����Ϣ
  TMaxBackupAnalyzeInfo = class
  public
    MaxBackupCountList : TMaxBackupCountList;
    MaxBackupSizeList : TMaxBackupSizeList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TMaxBackupCountInfo }

constructor TMaxBackupCountInfo.Create(_TypeName: string);
begin
  TypeName := _TypeName;
  FileCount := 0;
end;

{ TMaxBackupSizeInfo }

constructor TMaxBackupSizeInfo.Create(_TypeName: string);
begin
  TypeName := _TypeName;
  FileSize := 0;
end;

{ TMaxBackupPathInfo }

constructor TMaxBackupAnalyzeInfo.Create;
begin
  MaxBackupCountList := TMaxBackupCountList.Create;
  MaxBackupSizeList := TMaxBackupSizeList.Create;
end;

destructor TMaxBackupAnalyzeInfo.Destroy;
begin
  MaxBackupSizeList.Free;
  MaxBackupCountList.Free;
  inherited;
end;

end.
