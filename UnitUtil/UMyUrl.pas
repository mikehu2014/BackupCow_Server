unit UMyUrl;

interface

type

  MyUrl = class
  private
    class function getHome : string;
    class function getRegister : string;
    class function getDownload : string;
  public
    class function getIp : string;
    class function getTrialKey : string;
    class function getBatPayKey : string;
    class function getRarDllPath : string;
    class function getAppRunMark : string;
    class function getAdsRunMark : string;
    class function getDebug : string;
  public
    class function getGroupPcList : string;
    class function GroupSignup : string;
    class function GroupSignupHandle : string;
    class function GroupForgetPassword : string;
    class function GroupInstruction : string;
  end;

{$Region ' 产品 Url ' }

    // 父类
  TProductUrl = class
  public
    function BuyNow : string;virtual;abstract;
    function ContactUs : string;virtual;abstract;
    function OnlineManual : string;virtual;abstract;
    function EditionCompare : string;virtual;abstract;
    function Home : string;virtual;abstract;
  public
    function AppUpgrade : string;virtual;abstract;
  end;

    // 正常的产品 Url
  TNormalProductUrl = class( TProductUrl )
  public
    function BuyNow : string;override;
    function ContactUs : string;override;
    function OnlineManual : string;override;
    function EditionCompare : string;override;
    function Home : string;override;
  public
    function AppUpgrade : string;override;
  private
    function getHome : string;
  end;

    // 马来西亚的产品 Url
  TMaProductUrl = class( TProductUrl )
  public
    function BuyNow : string;override;
    function ContactUs : string;override;
    function OnlineManual : string;override;
    function EditionCompare : string;override;
    function Home : string;override;
  public
    function AppUpgrade : string;override;
  private
    function getHome : string;
  end;

    // 产品网站 Url
  MyProductUrl = class
  public
    class procedure IniUrl;
    class procedure UniniUrl;
  public
    class function BuyNow : string;
    class function ContactUs : string;
    class function OnlineManual : string;
    class function EditionCompare : string;
    class function Home : string;
    class function AppUpgrade : string;
  end;

{$EndRegion}


  MyOtherWebUrl = class
  public
    class function getFolderTransfer : string;
    class function getC4s : string;
    class function getDuplicateFilter : string;
    class function getKeywordCompeting : string;
    class function getTextFinding : string;
  end;

const
  HttpMarkRun_HardCode = 'HardCode';
  HttpMarkRun_PcID = 'PcID';
  HttpMarkRun_PcName = 'PcName';

const
  Url_BackuCowHome = 'http://www.backupcow.com/';
  Url_Register = 'register/';

//  Url_BackuCowHome = 'http://localhost:4113/BackupCow%20Register/';
//  Url_Register = '';

var
  ProductUrl : TProductUrl;

implementation

uses UAppSplitEdition;

{ MyUrl }

class function MyUrl.getHome: string;
begin
  Result := Url_BackuCowHome;
end;

class function MyUrl.getIp: string;
begin
  Result := getRegister + 'ip/default.aspx?act=getip';
end;

class function MyUrl.getRarDllPath: string;
begin
  Result := getDownload + 'unrar.dll';
end;

class function MyUrl.getRegister: string;
begin
  Result := getHome + Url_Register;
end;

class function MyUrl.getAdsRunMark: string;
begin
  Result := getRegister + 'Ads/AdsMark.aspx';
end;

class function MyUrl.getAppRunMark: string;
begin
  Result := getRegister + 'AppRunMark.aspx';
end;

class function MyUrl.getBatPayKey: string;
begin
  Result := getRegister + 'Activate/GetBatPayKey.aspx';
end;

class function MyUrl.getTrialKey: string;
begin
  Result := getRegister + 'Activate/GetTrialKey.aspx';
end;

class function MyUrl.GroupForgetPassword: string;
begin
  Result := getHome + 'ForgetPassword.aspx';
end;

class function MyUrl.GroupInstruction: string;
begin
  Result := getHome + 'Instruction.aspx';
end;

class function MyUrl.GroupSignup: string;
begin
  Result := getHome + 'remotegroup.aspx';
end;

class function MyUrl.GroupSignupHandle: string;
begin
  Result := getHome + 'RemoteGroupSignup.aspx';
end;

class function MyUrl.getDebug: string;
begin
  Result := getRegister + 'ErrorLogAdd.aspx';
end;

class function MyUrl.getDownload: string;
begin
  Result := getHome + 'Download/';
end;


class function MyUrl.getGroupPcList: string;
begin
  Result := getRegister + 'company/GetCompanyList.aspx';
end;

{ MyOtherWebUrl }

class function MyOtherWebUrl.getFolderTransfer: string;
begin
  Result := 'http://www.foldertransfer.com/';
end;

class function MyOtherWebUrl.getC4s: string;
begin
  Result := 'http://www.chat4support.com/';
end;

class function MyOtherWebUrl.getDuplicateFilter: string;
begin
  Result := 'http://www.duplicatefilter.com/';
end;

class function MyOtherWebUrl.getKeywordCompeting: string;
begin
  Result := 'http://www.keywordcompeting.com/';
end;

class function MyOtherWebUrl.getTextFinding: string;
begin
  Result := 'http://www.textfinding.com/';
end;

{ MyProductUrl }

class function MyProductUrl.AppUpgrade: string;
begin
  Result := ProductUrl.AppUpgrade;
end;

class function MyProductUrl.BuyNow: string;
begin
  Result := ProductUrl.BuyNow;
end;

class function MyProductUrl.ContactUs: string;
begin
  Result := ProductUrl.ContactUs;
end;

class function MyProductUrl.EditionCompare: string;
begin
  Result := ProductUrl.EditionCompare;
end;

class function MyProductUrl.Home: string;
begin
  Result := ProductUrl.Home;
end;

class procedure MyProductUrl.IniUrl;
begin
  if AppEdition_Now = AppEdition_MA then
    ProductUrl := TMaProductUrl.Create
  else
    ProductUrl := TNormalProductUrl.Create;
end;

class function MyProductUrl.OnlineManual: string;
begin
  Result := ProductUrl.OnlineManual;
end;

class procedure MyProductUrl.UniniUrl;
begin
  ProductUrl.Free;
end;

{ TNormalProductUrl }

function TNormalProductUrl.AppUpgrade: string;
begin
  Result := getHome + 'Download/' + 'BackupCowServer.inf';
end;

function TNormalProductUrl.BuyNow: string;
begin
  Result := getHome + 'BuyNow.asp';
end;

function TNormalProductUrl.ContactUs: string;
begin
  Result := getHome + 'support.asp';
end;

function TNormalProductUrl.EditionCompare: string;
begin
  Result := getHome + 'EditionComparison.asp';
end;

function TNormalProductUrl.getHome: string;
begin
  Result := Url_BackuCowHome;
end;

function TNormalProductUrl.Home: string;
begin
  Result := getHome;
end;

function TNormalProductUrl.OnlineManual: string;
begin
  Result := getHome + 'support.asp';
end;

{ TMaProductUrl }

function TMaProductUrl.AppUpgrade: string;
begin
  Result := Url_BackuCowHome + 'Download/' + 'MangoBackupUpgrade.inf';
end;

function TMaProductUrl.BuyNow: string;
begin
  Result := getHome + 'Buy_Now.htm';
end;

function TMaProductUrl.ContactUs: string;
begin
  Result := getHome + 'Contact_Us.htm';
end;

function TMaProductUrl.EditionCompare: string;
begin
  Result := getHome + 'features.htm';
end;

function TMaProductUrl.getHome: string;
begin
  Result := 'http://www.mangobackup.com/';
end;

function TMaProductUrl.Home: string;
begin
  Result := getHome;
end;

function TMaProductUrl.OnlineManual: string;
begin
  Result := getHome + 'Support_Welcome.htm';
end;

end.
