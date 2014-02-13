unit mp3_id3v1;

interface
uses
Windows,Classes,SysUtils;

type
TID3v1Rec = packed record
Tag : array[0..2] of AnsiChar;
Title : array[0..29] of AnsiChar;
Artist : array[0..29] of AnsiChar;
Album : array[0..29] of AnsiChar;
Year : array[0..3] of AnsiChar;
Comment : array[0..29] of AnsiChar;
Genre : Byte;
end;

TMP3Info=class
private
FhasTag: Boolean;
FGenre: string;
Ftitle: string;
FArtist: string;
FComment: string;
FAlbum: string;
FYear: string;

fFileName:string;
procedure SetAlbum(const Value: string);
procedure SetArtist(const Value: string);
procedure SetComment(const Value: string);
procedure SetGenre(const Value: string);
procedure SethasTag(const Value: Boolean);
procedure Settitle(const Value: string);
procedure SetYear(const Value: string);
public
constructor Create(fileName:string);
procedure GetMp3Info;
procedure WriteMp3Info;

published
property hasTag:Boolean read FhasTag write SethasTag;
property title:string read Ftitle write Settitle;
property Artist:string read FArtist write SetArtist;
property Comment:string read FComment write SetComment;
property Album:string read FAlbum write SetAlbum;
property Year:string read FYear write SetYear;
property Genre:string read FGenre write SetGenre;
end;

const
MaxID3Genre=147;
ID3Genre: array[0..MaxID3Genre] of string = (
'Blues', 'Classic Rock', 'Country', 'Dance', 'Disco', 'Funk', 'Grunge',
'Hip-Hop', 'Jazz', 'Metal', 'New Age', 'Oldies', 'Other', 'Pop', 'R&B',
'Rap', 'Reggae', 'Rock', 'Techno', 'Industrial', 'Alternative', 'Ska',
'Death Metal', 'Pranks', 'Soundtrack', 'Euro-Techno', 'Ambient',
'Trip-Hop', 'Vocal', 'Jazz+Funk', 'Fusion', 'Trance', 'Classical',
'Instrumental', 'Acid', 'House', 'Game', 'Sound Clip', 'Gospel',
'Noise', 'AlternRock', 'Bass', 'Soul', 'Punk', 'Space', 'Meditative',
'Instrumental Pop', 'Instrumental Rock', 'Ethnic', 'Gothic',
'Darkwave', 'Techno-Industrial', 'Electronic', 'Pop-Folk',
'Eurodance', 'Dream', 'Southern Rock', 'Comedy', 'Cult', 'Gangsta',
'Top 40', 'Christian Rap', 'Pop/Funk', 'Jungle', 'Native American',
'Cabaret', 'New Wave', 'Psychadelic', 'Rave', 'Showtunes', 'Trailer',
'Lo-Fi', 'Tribal', 'Acid Punk', 'Acid Jazz', 'Polka', 'Retro',
'Musical', 'Rock & Roll', 'Hard Rock', 'Folk', 'Folk-Rock',
'National Folk', 'Swing', 'Fast Fusion', 'Bebob', 'Latin', 'Revival',
'Celtic', 'Bluegrass', 'Avantgarde', 'Gothic Rock', 'Progressive Rock',
'Psychedelic Rock', 'Symphonic Rock', 'Slow Rock', 'Big Band',
'Chorus', 'Easy Listening', 'Acoustic', 'Humour', 'Speech', 'Chanson',
'Opera', 'Chamber Music', 'Sonata', 'Symphony', 'Booty Bass', 'Primus',
'Porn Groove', 'Satire', 'Slow Jam', 'Club', 'Tango', 'Samba',
'Folklore', 'Ballad', 'Power Ballad', 'Rhythmic Soul', 'Freestyle',
'Duet', 'Punk Rock', 'Drum Solo', 'Acapella', 'Euro-House', 'Dance Hall',
'Goa', 'Drum & Bass', 'Club-House', 'Hardcore', 'Terror', 'Indie',
'BritPop', 'Negerpunk', 'Polsk Punk', 'Beat', 'Christian Gangsta Rap',
'Heavy Metal', 'Black Metal', 'Crossover', 'Contemporary Christian',
'Christian Rock', 'Merengue', 'Salsa', 'Trash Metal', 'Anime', 'Jpop',
'Synthpop' {and probably more to come}
);

implementation


{ TMP3Info }

constructor TMP3Info.Create(fileName: string);
begin
fFileName := fileName;
end;

procedure TMP3Info.GetMp3Info;
var
id3rec:TID3v1Rec;
fsMp3:TFileStream;
buf : TByteArray;
begin
fsMp3:= TFileStream.Create(fFileName,fmOpenRead);
fsMp3.Seek(-128,soFromEnd);
fsMp3.Read(id3rec,SizeOf(id3rec));
fsMp3.Free;

if id3rec.Tag='TAG' then
begin
Ftitle := id3rec.Title;
FArtist := id3rec.Artist;
FComment := id3rec.Comment;
FAlbum := id3rec.Album;
FYear := id3rec.Year;
//FGenre := ID3Genre[id3rec.Genre];
FhasTag := True;
end
else
begin
FhasTag := False;
end;
end;

procedure TMP3Info.SetAlbum(const Value: string);
begin
FAlbum := Value;
end;

procedure TMP3Info.SetArtist(const Value: string);
begin
FArtist := Value;
end;

procedure TMP3Info.SetComment(const Value: string);
begin
FComment := Value;
end;

procedure TMP3Info.SetGenre(const Value: string);
begin
FGenre := Value;
end;

procedure TMP3Info.SethasTag(const Value: Boolean);
begin
FhasTag := Value;
end;

procedure TMP3Info.Settitle(const Value: string);
begin
Ftitle := Value;
end;

procedure TMP3Info.SetYear(const Value: string);
begin
FYear := Value;
end;

procedure TMP3Info.WriteMp3Info;
var
id3Tag : TID3v1Rec;
fMp3 : TFileStream;

function SearchGenre(sGenre:string):Byte;
var
i:Byte;
begin
result:=0;
for i := 0 to MaxID3Genre do
begin
if ID3Genre[i] = sGenre then
result:=i;
end;
end;
begin

if not hasTag then
exit;

StrPCopy(id3Tag.Tag,'TAG');

if Length(Ftitle) > 30 then
SetLength(Ftitle,30);
StrPCopy(id3Tag.Title,Ftitle);

if Length(FArtist) > 30 then
SetLength(FArtist,30);
StrPCopy(id3Tag.Artist,FArtist);

if Length(FAlbum) > 30 then
SetLength(FAlbum,30);
StrPCopy(id3Tag.Album,FAlbum);

if Length(FYear)>4 then
SetLength(FYear,4);
StrPCopy(id3Tag.Year,FYear);

if Length(FComment) > 30 then
SetLength(FComment,30);
StrPCopy(id3Tag.Comment,FComment);

id3Tag.Genre := SearchGenre(FGenre);

fMp3 := TFileStream.Create(fFileName,fmOpenWrite);
fMp3.Seek(-128,soFromEnd);
fMp3.Write(id3Tag,SizeOf(id3Tag));

fMp3.Free;
end;

end.

