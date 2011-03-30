program Mapeditor_Pacman3D;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Mapeditor - Pacman 3D';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
