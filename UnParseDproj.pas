unit UnParseDproj;

interface

uses
  System.Sysutils, System.Classes,
  Winapi.Ole2,
  Xml.XMLIntf,
  Xml.XMLDoc;

type

  TDprojParser = class
    private
      FXMLDocument : IXMLDocument;
      FDprojFile : string;
      FVersionString : string;
      procedure SetDprojFile(const Value: string);
      procedure SetVersionString(const Value: string);
    public
      property DprojFile : string read FDprojFile write SetDprojFile;
      property VersionString : string read FVersionString write SetVersionString;
      procedure ChangeVersion;
      procedure GetVersionInfo(verInfo : TStrings);
      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses
  Str_Ops;

{ TDprojParser }

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TDprojParser.ChangeVersion;
var
  Project, Node, VerInfo_Keys, VerInfo_MajorVer, VerInfo_MinorVer, VerInfo_Release, VerInfo_Build: IXMLNode;
  I, J, K: Integer;
  Keys_String: String;
  newBuild : String;
  Keys : TArray<string>;
  Version: TArray<string>;
  CurrentItems: TArray<string>;
  NewItems : TArray<string>;

begin
  NewItems := FVersionString.Split(['.']);

  try
    FXMLDocument.LoadFromFile(DprojFile);
    Project := FXMLDocument.ChildNodes.First;
    J := Project.ChildNodes.Count - 1;

    for I := 0 to J do
    begin
      newBuild := '';

      Node := Project.ChildNodes.Nodes[I];

      VerInfo_MajorVer := Node.ChildNodes.FindNode('VerInfo_MajorVer');
      if VerInfo_MajorVer <> nil then
      begin
        VerInfo_MajorVer.NodeValue := NewItems[0];
      end;

      VerInfo_MinorVer := Node.ChildNodes.FindNode('VerInfo_MinorVer');
      if VerInfo_MinorVer <> nil then
      begin
        VerInfo_MinorVer.NodeValue := NewItems[1];
      end;

      VerInfo_Release := Node.ChildNodes.FindNode('VerInfo_Release');
      if VerInfo_Release <> nil then
      begin
        VerInfo_Release.NodeValue := NewItems[2];
      end;

      VerInfo_Build := Node.ChildNodes.FindNode('VerInfo_Build');
      if VerInfo_Build <> nil then
      begin
        newBuild := VerInfo_Build.NodeValue;
        if (Length(NewItems) = 4) then
        begin
          VerInfo_Build.NodeValue := NewItems[3];
        end;
      end;

      VerInfo_Keys := Node.ChildNodes.FindNode('VerInfo_Keys');
      if VerInfo_Keys <> nil then
      begin
        Keys_String := VerInfo_Keys.NodeValue;
        Keys := Keys_String.Split([';']);
        for K := 0 to Length(Keys) - 1  do
        begin
          Version := Keys[K].Split(['=']);

          if ((Version[0]= 'FileVersion') or
              (Version[0]= 'ProductVersion')) then
          begin
            if (Length(NewItems) = 4) then
            begin
              // The Build has been given (i.e. being forced)
              newBuild := NewItems[3];
            end // if
            else if (newBuild = '') then
            begin
              // The Build should not be changed, and was not found in
              // a VerInfo_Build node.
              CurrentItems := Version[1].Split(['.']);
              if (Length(CurrentItems) = 4) then
              begin
                newBuild := CurrentItems[3];
              end
              else
              begin
                newBuild := '0';
              end;
            end;

            if Version[0]= 'FileVersion' then
            begin
              Keys[K] := 'FileVersion=' +
                         NewItems[0] + '.' + NewItems[1] + '.' + NewItems[2] + '.' + newBuild;
            end
            else if Version[0]= 'ProductVersion' then
            begin
              Keys[K] := 'ProductVersion=' +
                         NewItems[0] + '.' + NewItems[1] + '.' + NewItems[2] + '.' + newBuild;
            end;
          end;
        end;
        Keys_String := '';
        for K := 0 to Length(Keys) - 1 do
          Keys_String := Keys_String + Keys[K] + ';';
        Keys_String := Keys_String.Substring(0,Keys_String.Length -1);
        VerInfo_Keys.NodeValue := Keys_String;
      end;

      //!! How to handle build?

    end; // for

    FXMLDocument.SaveToFile(Dprojfile);
  except
    on E: Exception do
      WriteLn(E.ClassName + ':' + E.Message)
  end;
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TDProjParser.GetVersionInfo(verInfo : TStrings);
var
  Project, Node, VerInfo_Keys: IXMLNode;
  I, J, K: Integer;
  Keys_String: String;
  Keys : TArray<string>;
  Version: TArray<string>;

begin
  verInfo.Clear;

  try
    FXMLDocument.LoadFromFile(DprojFile);
    Project := FXMLDocument.ChildNodes.First;
    J := Project.ChildNodes.Count - 1;
    for I := 0 to J do
    begin
      Node := Project.ChildNodes.Nodes[I];
      VerInfo_Keys := Node.ChildNodes.FindNode('VerInfo_Keys');
      if (VerInfo_Keys <> nil) then
      begin
        Keys_String := VerInfo_Keys.NodeValue;
        verInfo.Add(Keys_String);
//        Keys := Keys_String.Split([';']);
//        for K := 0 to Length(Keys) - 1  do
//        begin
//          Version := Keys[K].Split(['=']);
//          if Version[0]= 'FileVersion' then
//            Keys[K] := 'FileVersion='+FVersionString;
//          if Version[0]= 'ProductVersion' then
//            Keys[K] := 'ProductVersion='+FVersionString;
//        end;
      end;
    end;
  except
    on E: Exception do
      WriteLn(E.ClassName + ':' + E.Message)
  end;
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
constructor TDprojParser.Create;
begin
  FXMLDocument := TXMLDocument.Create(nil);
  FXMLDocument.ParseOptions := FXMLDocument.ParseOptions+[poPreserveWhiteSpace];
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
destructor TDprojParser.Destroy;
begin
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TDprojParser.SetDprojFile(const Value: string);
begin
  FDprojFile := Value;
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TDprojParser.SetVersionString(const Value: string);
begin
  FVersionString := Value;
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
initialization
  CoInitialize(nil);

end.
