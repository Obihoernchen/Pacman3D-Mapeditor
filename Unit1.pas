unit Unit1;
 //########################################
 //#-------- Pacman 3D Mapeditor ---------#
 //#--------------------------------------#
 //#--------- by Markus Hilger -----------#
 //#--------------------------------------#
 //#-------------- © 2011 ----------------#
 //#--------------------------------------#
 //########################################
interface

uses
  Windows, Graphics, Forms, SysUtils, Variants, Classes, Controls, ExtCtrls,
  Menus, Dialogs, StdCtrls;

const
  mapSize = 35; // Mapgröße (maxX und maxY)

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Datei1: TMenuItem;
    NeueMap1: TMenuItem;
    Mapladen1: TMenuItem;
    Maospeichern1: TMenuItem;
    Beenden1: TMenuItem;
    About1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Shape1: TShape;
    Label1: TLabel;
    Shape2: TShape;
    Label2: TLabel;
    Shape3: TShape;
    Label3: TLabel;
    About2: TMenuItem;
    Help1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); // Leertaste gedrückt?
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); // Leertaste losgelassen?
    procedure Beenden1Click(Sender: TObject);
    procedure NeueMap1Click(Sender: TObject);
    procedure load; // Laden
    procedure save; // Speichern
    procedure Mapladen1Click(Sender: TObject);
    procedure Maospeichern1Click(Sender: TObject);
    procedure About2Click(Sender: TObject);
    procedure Help1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    procedure SetzeTeil(Sender: TObject; Button: TMouseButton;
                      Shift: TShiftState; X, Y: Integer); // Teil durch Klick setzen
    procedure SetzeTeilSchnell(Sender: TObject);          // Teil durch "überfahren" setzen (Leertaste gedrückt)
  end;

  TField = array[1..mapSize,1..mapSize] of integer; // 2D Feld mit Daten der Teile

  TRMap = record  // Record zum speichern/laden
     name: string[20];  // für die Zukunft...
     maxx, maxy: integer; // für die Zukunft...
     Field: TField;
  end;

  TTeil = class(TShape) // Die Shapes
     private
      X: integer;       // X Koordinate
      Y: integer;       // Y Koordinate
     public
      constructor create(AOwner: TComponent); override; // Constructor
  end;

var
  Form1: TForm1;
  Teil: array of TTeil; // Ein dynamisches array des Shapes TTeil erstellen
  Map: TRMap;           // zum speichern/laden für Mapfile

implementation
{$R *.dfm}

constructor TTeil.Create(AOwner: TComponent); // Constructor
begin
  Inherited;  // vererbt
  Shape := stSquare;  // Quadrat
  Width := 20;
  Height := 20;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  I,X2,Y2,L: integer;
begin
  openDialog1.InitialDir := GetCurrentDir + '\maps'; // in Ordner \maps wechseln
  saveDialog1.InitialDir := GetCurrentDir + '\maps'; // in Ordner \maps wechseln
  setLength(Teil,mapSize*mapSize);  // Länge des arrays Teil setzen
  // für die Zukunft
  Map.name:='Testmap';
  Map.maxy:=mapSize;
  Map.maxx:=mapSize;
  // ----------
  X2:=1;
  Y2:=1;
  for I := 0 to Length(Teil)-1 do
    begin
      Teil[I] := TTeil.Create(Form1);
      with Teil[I] do
        begin
          Parent := self;
          OnMouseDown := SetzeTeil; // Bei Klick --> SetzeTeil
          Left := X2*19;  // Position
          Top := Y2*19;   // Position
          X := X2;        // X Koordinate (für Mapfile)
          Y := Y2;        // Y Koordinate (für Mapfile)
        end;
      for L := 1 to Length(Teil)-1 do
        begin
          if I+1 = L*mapSize then // Zeilenumbruch
            begin
              X2:=0;  // X wieder 0 setzen
              inc(Y2); // Y erhöhen (nächste Zeile)
            end;
        end;
      inc(X2);
    end;
   Help1Click(Form1);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;  // Leertaste gedrückt
  Shift: TShiftState);
var
  I:integer;
begin
  if Key = VK_SPACE then
    for I := 0 to Length(Teil)-1 do
      Teil[I].OnMouseEnter := SetzeTeilSchnell; // Wenn Maus auf Shapes --> SetzeTeilSchnell
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); // Leertaste losgelassen
var
  I:integer;
begin
  if Key = VK_SPACE then
    for I := 0 to Length(Teil)-1 do
      Teil[I].OnMouseEnter := nil;  // nichts mehr beim machen, wenn Maus auf Shapes
end;


procedure TForm1.SetzeTeil(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);               // Klicken mit der Maus
begin
  // Setzen
  if Button = mbLeft then
  case Map.Field[TTeil(Sender).X,TTeil(Sender).Y] of
   // Weg --> Wand
   0: begin TTeil(Sender).Brush.Color:=clBlue;
            Map.Field[TTeil(Sender).X,TTeil(Sender).Y] := 1;
      end;
   // Wand --> PowerUp
   1: begin TTeil(Sender).Brush.Color:=clRed;
            Map.Field[TTeil(Sender).X,TTeil(Sender).Y] := 2;
      end;
  end;
  // Löschen
  if Button = mbRight then
  begin
    TTeil(Sender).Brush.Color:=clWhite;
    Map.Field[TTeil(Sender).X,TTeil(Sender).Y] := 0;
  end;
end;

procedure TForm1.SetzeTeilSchnell(Sender: TObject); // Leertaste gedrückt
begin
  // Setzen
  case Map.Field[TTeil(Sender).X,TTeil(Sender).Y] of
   // Weg --> Wand
   0: begin TTeil(Sender).Brush.Color:=clBlue;
            Map.Field[TTeil(Sender).X,TTeil(Sender).Y] := 1;
      end;
   // PowerUp --> Wand
   2: begin TTeil(Sender).Brush.Color:=clBlue;
            Map.Field[TTeil(Sender).X,TTeil(Sender).Y] := 1;
      end;
  end;
end;

procedure TForm1.save;  // Map speichern procedure
var
  mapfile: file of TRMap;
begin
  if savedialog1.Execute then
  begin
    assignfile(mapfile,savedialog1.filename);
    ReWrite(mapfile);
    write(mapfile, Map);  // Mapfile schreibens
    closefile(mapfile);
  end;
end;

procedure TForm1.load;  // Map laden procedure
var mapfile: file of TRmap;
    I: integer;
begin
  if opendialog1.Execute then
  begin
    assignfile(mapfile,opendialog1.filename);
    reset(mapfile);
    read(mapfile,Map);  // Mapfile einlesen
    closefile(mapfile);
  end;
  Map.maxx:= mapSize;
  Map.maxy:= mapSize;
  for I := 0 to Length(Teil)-1 do
    case Map.Field[Teil[I].X,Teil[I].Y] of // Shapes anhand der Daten einfärben
      0: Teil[I].Brush.Color := clWhite;
      1: Teil[I].Brush.Color := clBlue;
      2: Teil[I].Brush.Color := clRed;
    end;
end;

procedure TForm1.Maospeichern1Click(Sender: TObject); // Map speichern
begin
  save;
end;

procedure TForm1.Mapladen1Click(Sender: TObject); // Map laden
begin
  load;
end;

procedure TForm1.NeueMap1Click(Sender: TObject);  // Neue Map
var
  I:integer;
begin
  for I := 0 to Length(Teil)-1 do
    begin
      with Teil[I] do
        begin
          Brush.Color := clWhite; // Alle Shapes wieder weiß färben
          Map.Field[X,Y] := 0;  // Alle Werte wieder auf 0 setzen
        end;
    end;
end;

procedure TForm1.Help1Click(Sender: TObject); // Help
begin
    showmessage('Nutze deine Maus um eine Map zu erstellen'+#13+
              'Rechte Maustaste = Wand'+#13+
              'Doppelklick = Kraftpille'+#13+
              'Leertaste gedrückt halten = Wände ohne zu klicken zeichnen'+#13+
              'Linke Maustaste = löschen');
end;

procedure TForm1.About2Click(Sender: TObject);
begin
  showmessage('Mapeditor for Pacman3D by Markus Hilger');
end;

procedure TForm1.Beenden1Click(Sender: TObject);  // Beenden
begin
  close;
end;

end.
