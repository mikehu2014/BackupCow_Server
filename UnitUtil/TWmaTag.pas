unit TWmaTag;

interface
uses
  Classes, SysUtils;
const
  Wma_head=#48#38#178#117#142#102#207#17#166#217#0#170#0#98#206#108;     //Wma�ļ�ͷ16�ֽ�һ��Ҫ�����
  Tag_head=#51#38#178#117#142#102#207#17#166#217#0#170#0#98#206#108;     //��ǩ��֡ͷ
  ExTag_head=#64#164#208#210#7#227#210#17#151#240#0#160#201#94#168#80;   //��չ��ǩ��֡ͷ
  ExTagNumber=10;                                                        //���ദ�����չ��ǩ��������
var
  Flag:array [1..ExTagNumber] of WideString;                             //����������չ��ǩ������
type
  TWma_Tag =class (TObject)
    private
      { Private declarations }
      FVersion: WideString;
      FAllsize: int64;
      FTitle:WideString;
      FArtist: WideString;
      FCopyright:WideString;
      FDescription:WideString;
      FAlbumTitle: WideString;
      FYear: WideString;
      FGenre:WideString;
      FTrackNumber: WideString;
      FTrack:WideString;
      FUserWebURL:WideString;
      FURL: WideString;
      FLyrics:WideString;
      FEncodedBy:WideString;
      procedure FSetTitle(const NewTitle: WideString);
      procedure FSetArtist(const NewArtist: WideString);
      procedure FSetCopyright(const NewCopyright:WideString);
      procedure FSetDescription(const NewDescription:WideString);
      procedure FSetAlbumTitle(const NewAlbum: WideString);
      procedure FSetYear(const NewYear: WideString);
      procedure FSetGenre(const NewGenre:WideString);
      procedure FSetTrackNumber(const NewTrackNo: WideString);
      procedure FSetTrack(const NewTrack:WideString);
      procedure FSetUserWebURL(const NewUWU:WideString);
      procedure FSetURL(const NewURL:WideString);
      procedure FSetLyrics(const NewLyrics:WideString);
      procedure FSetEncodedBy(const NewEncodedby:WideString);
    public
      { Public declarations }
      constructor Create;
      procedure ResetData;                                                   //��ն�����ԭ������
      function ReadFromFile(const FileName: String): Boolean;
      function SaveToFile(const FileName: String): Boolean;
      property Version: WideString read FVersion;
      property Title: WideString read FTitle write FSetTitle;
      property Artist: WideString read FArtist write FSetArtist;
      property Copyright:WideString read FCopyright write FSetCopyright;
      property Description:WideString read FDescription write FSetDescription;
      property AlbumTitle: WideString read FAlbumTitle write FSetAlbumTitle;
      property Year: WideString read FYear write FSetYear;
      property TrackNumber: WideString read FTrackNumber write FSetTrackNumber;
      property Genre: WideString read FGenre write FSetGenre;
      property Track: WideString read FTrack write FSetTrack;
      property UserWebURL: WideString read FUserWebURL write FSetUserWebURL;
      property URL: WideString read FURL write FSetURL;
      property Lyrics: WideString read FLyrics write FSetLyrics;
      property EncodedBy: WideString read FEncodedBy write FSetEncodedBy;
  end;
implementation
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetTitle(const NewTitle: WideString);
begin
   FTitle:=TrimRight(NewTitle);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetArtist(const NewArtist: WideString);
begin
   FArtist:=TrimRight(NewArtist);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetCopyright(const NewCopyright:WideString);
begin
   FCopyright:=TrimRight(NewCopyright);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetDescription(const NewDescription:WideString);
begin
   FDescription:=TrimRight(NewDescription);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetAlbumTitle(const NewAlbum: WideString);
begin
   FAlbumTitle:=TrimRight(NewAlbum);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetYear(const NewYear: WideString);
begin
   FYear:=TrimRight(NewYear);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetGenre(const NewGenre:WideString);
begin
   FGenre:=TrimRight(NewGenre);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetTrackNumber(const NewTrackNo: WideString);
begin
   FTrackNumber:=TrimRight(NewTrackNo);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetTrack(const NewTrack:WideString);
begin
   FTrack:=TrimRight(NewTrack);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetUserWebURL(const NewUWU:WideString);
begin
   FUserWebURL:=TrimRight(NewUWU);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetURL(const NewURL:WideString);
begin
   FURL:=TrimRight(NewURL);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetLyrics(const NewLyrics:WideString);
begin
   FLyrics:=TrimRight(NewLyrics);
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.FSetEncodedBy(const NewEncodedby:WideString);
begin
   FEncodedBy:=TrimRight(NewEncodedby);
end;
{-------------------------------------------------------------------------------}
constructor TWma_Tag.Create;
begin
  inherited;
  ResetData;
end;
{-------------------------------------------------------------------------------}
procedure TWma_Tag.ResetData;
begin
      FVersion:= '';
      FAllsize:= 0;
      FTitle:= '';
      FArtist:= '';
      FCopyright:= '';
      FDescription:= '';
      FAlbumTitle:= '';
      FYear:= '';
      FGenre:= '';
      FTrackNumber:= '';
      FTrack:= '';
      FUserWebURL:= '';
      FURL:= '';
      FLyrics:= '';
      FEncodedBy:= '';
end;
{-------------------------------------------------------------------------------}
function TWma_Tag.ReadFromFile(const FileName: String): Boolean;
var
  TagStream:TFileStream;                                         //��WMA�ļ�����
  head:ansistring;
  size:Int64;
  temps,ExValue:WideString;
  Tagsize:array[1..5] of SmallInt;
  i,TraNo:Integer;
  ExNo,Exsize,Reserve,ExValueSize:SmallInt;
begin
  Result:=false;
  if ( not FileExists(Filename) ) then Exit;                      //�ļ�������ʱ�˳�
  Setlength(head,16);
  TagStream:=TFileStream.Create(Filename,fmOpenRead or fmShareDenyNone);
  try
    TagStream.ReadBuffer(head[1],16);                            //��ȡWMA�ļ�ͷ16�ֽ�
    TagStream.ReadBuffer(size,sizeof(size));
  except
    TagStream.Free;
    Exit;
  end;
  if head<>Wma_head then begin TagStream.Free; Exit; end;        //����WMA�ļ�ʱ�˳�
  FAllsize:=Size;
  TagStream.Position:=30;
  try                               //��ָ���Ƶ���һ��֡ͷ
  While TagStream.Position<FAllsize do                           //��ָ�벻��ĩβʱһֱ��ÿһ��֡
  begin
    TagStream.ReadBuffer(head[1],16);
    TagStream.ReadBuffer(size,sizeof(size));
    if head=Tag_head then  //��Ϊ�����䣩��ǩʱ
    begin
      for i:=1 to 5 do
        TagStream.ReadBuffer(Tagsize[i],2);
      for i:=1 to 5 do
        if Tagsize[i]>0 then
          begin
            setlength(temps,(Tagsize[i] div 2)-1);
            TagStream.ReadBuffer(temps[1],Tagsize[i]);
            case i of
               1:FTitle:=temps;
               2:FArtist:=temps;
               3:FCopyright:=temps;
               4:FDescription:=temps;
             end;
            end;
    end
    else
    if head=ExTag_head then                                 //��Ϊ��չ��ǩʱ
       begin
          TagStream.ReadBuffer(ExNo,2);                          //����һ���ж��ٸ���չ��ǩ
          for i:=1 to ExNo do
            begin
             TagStream.ReadBuffer(Exsize,2);
             SetLength(temps,(Exsize div 2)-1);
             TagStream.Read(temps[1],Exsize);
             TagStream.ReadBuffer(Reserve,2);
             TagStream.ReadBuffer(ExValueSize,2);
             if (Reserve=3) then
               begin
                TagStream.ReadBuffer(TraNo,4);
                if temps=Flag[10] then FTrackNumber:=InttoStr(TraNo)
                else if temps=Flag[5] then FTrack:=InttoStr(TraNo);
              end
             else
               begin
                 if ExValueSize > 2 then SetLength(ExValue,(ExValueSize div 2)-1)
                 else SetLength(ExValue,2);
                 if Exvaluesize>0 then
                 begin
                 TagStream.ReadBuffer(ExValue[1],ExValueSize);
                 if temps=Flag[1] then FAlbumTitle:=ExValue
                 else if temps=Flag[2] then FEncodedBy:=ExValue
                 else if temps=Flag[3] then FGenre:=ExValue
                 else if temps=Flag[4] then FLyrics:=ExValue
                 else if temps=Flag[5] then FTrack:=ExValue
                 else if temps=Flag[6] then FYear:=ExValue
                 else if temps=Flag[7] then FURL:=ExValue
                 else if temps=Flag[8] then FUserWebURL:=ExValue
                 else if temps=Flag[9] then FVersion:=ExValue
                 else if temps=Flag[10] then FTrackNumber:=ExValue;
                 end;
              end;
          end;
       end
    else
    TagStream.Position:=TagStream.Position-24+size;
  end;
  except
  end;
  TagStream.Free;
  Result:=true;
end;
{-------------------------------------------------------------------------------}
function TWma_Tag.SaveToFile(const FileName: String): Boolean;
var
  TagStream:TMemoryStream;
  WMAStream:TMemorystream;
  Myfile:TFileStream;
  Size,Tsize:Int64;
  i,j:integer;
  ExCount,ExNo:SmallInt;
  Exsize,Reserve,ExValueSize:SmallInt;
  Tagsize:array[1..5] of SmallInt;
  head:string;
  temps,ExValue:WideString;
  Inflag:boolean;
   procedure WriteExTag(const Name:Widestring;const Re:SmallInt;const Value:Widestring);
    var                                                 //����д��չ��ǩ���ӹ���
    tempsize:Smallint;
   begin
    tempsize:=Length(Name)*2+2;                         //�������ִ�С
    TagStream.WriteBuffer(tempsize,2);                  //д�����ִ�С
    TagStream.WriteBuffer(Name[1],tempsize);            // д������
    TagStream.WriteBuffer(Re,2);                        //д�뱣����
    tempsize:=Length(Value)*2+2;                        //����ֵ��С
    TagStream.WriteBuffer(tempsize,2);                  //д��ֵ��С
    TagStream.WriteBuffer(Value[1],tempsize);           //д��ֵ
    ExCount:=ExCount+1;                                 //��д�����չ��ǩ��Ŀ��һ
   end;

begin
  Result:=false;
  Setlength(head,16);
  if ( not FileExists(Filename) ) then Exit;                 //�ļ�������ʱ�˳�
  Myfile:=TFileStream.Create(Filename,fmOpenRead or fmShareDenyNone );
  try
    Myfile.ReadBuffer(head[1],16);
    Myfile.ReadBuffer(size,sizeof(size));
    FAllSize:=size;
  except
    Myfile.Free;
    Exit;
  end;
  if head<>Wma_head then begin Myfile.Free; Exit; end;        //������WMA�ļ�ʱ�˳�
  Myfile.Position:=0;
  WMAStream:=TMemorystream.Create;                            //һ�����������µı�ǩ��Ϣ����
  WMAStream.CopyFrom(Myfile,30);
    TagStream:=TMemoryStream.Create;                          //���´������������䣩��ǩ�������Ƶ�WMAStream��
    TagStream.WriteBuffer(Tag_head[1],16);
    TagStream.WriteBuffer(Tsize,8);
    for i:=1 to 5 do Tagsize[i]:=0;
    if(FTitle<>'') then Tagsize[1]:=length(FTitle)*2+2;
    if(FArtist<>'') then Tagsize[2]:=length(FArtist)*2+2;
    if(FCopyright<>'') then Tagsize[3]:=length(FCopyright)*2+2;
    if(FDescription<>'') then Tagsize[4]:=length(FDescription)*2+2;
    for i:=1 to 5 do TagStream.WriteBuffer(Tagsize[i],2);
    if(FTitle<>'') then TagStream.WriteBuffer(FTitle[1],Tagsize[1]);
    if(FArtist<>'') then TagStream.WriteBuffer(FArtist[1],Tagsize[2]);
    if(FCopyright<>'') then TagStream.WriteBuffer(FCopyright[1],Tagsize[3]);
    if(FDescription<>'') then TagStream.WriteBuffer(FDescription[1],Tagsize[4]);
    Tsize:=Tagstream.Size;
    Tagstream.Position:=16;
    Tagstream.WriteBuffer(Tsize,8);
    Tagstream.Position:=0;
    WMAStream.CopyFrom(Tagstream,Tsize);
    Tagstream.Free;
  Myfile.Position:=30;
  While Myfile.Position<FAllsize do
    begin
     Myfile.ReadBuffer(head[1],16);
     Myfile.ReadBuffer(size,8);
     if head=Tag_head then Myfile.Position:=Myfile.Position-24+size   //������ԭ���ģ����䣩��ǩʱ��ֱ������
     else if head=ExTag_head then                                     //��������չ��ǩʱ
       begin
        ExCount:=0;
        Tagstream:=TMemorystream.Create;
        Tagstream.WriteBuffer(ExTag_head[1],16);
        TagStream.WriteBuffer(Tsize,8);
        TagStream.WriteBuffer(ExCount,2);
        if FAlbumTitle<>'' then WriteExTag(Flag[1],0,FAlbumTitle);      //��д�뱾���д����һЩ��չ��ǩ
        if FEncodedBy<>'' then  WriteExTag(Flag[2],0,FEncodedBy);
        if FGenre<>'' then  WriteExTag(Flag[3],0,FGenre);
        if FLyrics<>'' then WriteExTag(Flag[4],0,FLyrics);
        if FTrack<>'' then WriteExTag(Flag[5],0,FTrack);
        if FYear<>'' then WriteExTag(Flag[6],0,FYear);
        if FURL<>'' then WriteExTag(Flag[7],0,FURL);
        if FUserWebURL<>'' then WriteExTag(Flag[8],0,FUserWebURL);
        if FVersion<>'' then WriteExTag(Flag[9],0,FVersion);
        if FTrackNumber<>'' then WriteExTag(Flag[10],0,FTrackNumber);
        Myfile.ReadBuffer(ExNo,2);
        for i:=1 to ExNo do
          begin                                                          //�����ļ���ԭ�е���չ��ǩ
           Myfile.ReadBuffer(ExSize,2);
           SetLength(temps,(Exsize div 2) -1);
           Myfile.ReadBuffer(temps[1],ExSize);
           Myfile.ReadBuffer(Reserve,2);
           Myfile.ReadBuffer(ExValueSize,2);
           if ExValueSize > 2 then SetLength(ExValue,(ExValueSize div 2)-1)
           else SetLength(ExValue,2);
           if ExValueSize>0 then
             begin
             Myfile.ReadBuffer(ExValue[1],ExValueSize);
             Inflag:=False;
             for j:=1 to ExTagNumber do
               if temps=Flag[j] then Inflag:=True;
             if (not Inflag) then WriteExTag(temps,Reserve,ExValue);     //�������ڱ��ദ�����չ��ǩ��Χʱ��ֱ��ԭ��д��
             end;
          end;
         Tsize:=TagStream.Size;
         Tagstream.Position:=16;
         Tagstream.WriteBuffer(Tsize,8);                                  //д����չ��ǩʵ�ʴ�С
         Tagstream.Position:=24;
         Tagstream.WriteBuffer(ExCount,2);
         Tagstream.Position:=0;                                           //д����չ��ǩʵ����Ŀ
         WMAStream.CopyFrom(Tagstream,Tsize);                             //����չ��ǩ֡���Ƶ�WMAStreamĩβ
         Tagstream.Free;
       end
     else                                                                //����������֡ʱ��ֱ�Ӹ�������֡
       begin
       Myfile.Position:=Myfile.Position-24;
       WMAStream.CopyFrom(Myfile,size);
       end;
     end;

    Tsize:=WMAStream.Size;
    WMAStream.Position:=16;
    WMAStream.WriteBuffer(TSize,8);                                        //д��������ǩ��ʵ�ʴ�С
    WMAStream.Position:=TSize;                                             //ָ���Ƶ�ĩβ
    Myfile.Position:=FAllsize;                                             //��Myfileָ��Ҳ�Ƶ���ǩĩβ
    WMAStream.CopyFrom(Myfile,Myfile.Size-FAllsize);                       //��Myfile�е��������ݸ��Ƶ�WMAStream��
    Myfile.Free;
     try
      WMAStream.SaveToFile(Filename);                                       //��WMAStream����
     except
      WMAStream.Free;
      Exit;
      end;
    WMAStream.Free;
    Result:=True;
end;
{-------------------------------------------------------------------------------}
initialization
  begin
  Flag[1]:='WM/AlbumTitle';
  Flag[2]:='WM/EncodedBy';
  Flag[3]:='WM/Genre';
  Flag[4]:='WM/Lyrics';
  Flag[5]:='WM/Track';
  Flag[6]:='WM/Year';
  Flag[7]:='WM/URL';
  Flag[8]:='WM/UserWebURL';
  Flag[9]:='WMFSDKVersion';
  Flag[10]:='WM/TrackNumber';
  end;

end.
