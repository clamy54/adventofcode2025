{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils,math;

const nomfichier='input.txt';

type tableauint = array of LongInt;

var elements:TStringList;

procedure Split(const Delimiter: Char; Input: string; const Strings: TStrings);
var a: int64;
    subs:string;

begin
   Assert(Assigned(Strings)) ;
   Strings.Clear;
   subs:='';
   for a:=1 to length(Input) do
   begin
      if Input[a]=Delimiter then
      begin
        Strings.Add(subs);
        subs:='';
      end
      else
        subs:=subs+Input[a];
   end;
   Strings.Add(subs);
end;

procedure ParseLigne(ligne: string; var nblumiere: Integer;
                    var cible: LongInt; var boutons: tableauint);
var
  a, b, masque: Integer;
  pat, btn, partie: string;
begin
  // supprimer la partie {}
  a := Pos('{', ligne);
  if a > 0 then
    ligne := Copy(ligne, 1, a - 1);

  // extraire le pattern []
  a := Pos('[', ligne);
  b := Pos(']', ligne);
  pat := Copy(ligne, a + 1, b - a - 1);
  nblumiere := Length(pat);

  // calcul du masque
  cible := 0;
  for a := 1 to nblumiere do
    if pat[a] = '#' then
      cible := cible or (1 shl (a - 1));

  // extraire chaque bouton ()
  SetLength(boutons, 0);

  while True do
  begin
    a := Pos('(', ligne);
    if a = 0 then Break;
    b := Pos(')', ligne);
    if b = 0 then Break;

    btn := Copy(ligne, a + 1, b - a - 1);
    Delete(ligne, 1, b);

    // convertir liste en masque
    masque := 0;
    if btn <> '' then
    begin
      Split(',',btn,elements);
      for a:=0 to elements.Count-1 do
        if Trim(elements[a]) <> '' then
          masque := masque or (1 shl StrToInt(Trim(elements[a])));
    end;

    SetLength(boutons, Length(boutons) + 1);
    boutons[High(boutons)] := masque;
  end;
end;


function MinPressions(nblumiere: Integer; cible: LongInt; const boutons: tableauint): Integer;
var
  maxetat, a: LongInt;
  dist: array of Integer;
  q: array of LongInt;
  debut, fin: Integer;
  etat, nouveletat: LongInt;
begin
  if cible = 0 then Exit(0);
  maxetat := Trunc(IntPower(2, nblumiere));
  SetLength(dist, maxetat);
  for a := 0 to maxetat - 1 do
  begin
    dist[a] := -1;
  end;
  SetLength(q, maxetat);
  debut := 0; 
  fin := 0;
  dist[0] := 0;
  q[fin] := 0; 
  Inc(fin);
  while debut < fin do
  begin
    etat := q[debut]; 
    Inc(debut);
    for a := 0 to High(boutons) do
    begin
      nouveletat := etat xor boutons[a];
      if dist[nouveletat] = -1 then
      begin
        dist[nouveletat] := dist[etat] + 1;
        if nouveletat = cible then
        begin
          Exit(dist[nouveletat]);
        end;
        q[fin] := nouveletat; 
        Inc(fin);
      end;
    end;
  end;
  MinPressions:=-1;
end;


function Solve(nom:string): LongInt;
var
  myFile: TextFile;
  ligne: string;
  nblumiere: Integer;
  cible: LongInt;
  boutons: tableauint;
  pressions, score: LongInt;
begin
  AssignFile(myFile, nom);
  Reset(myFile);

  score := 0;

  while not EOF(myFile) do
  begin
    ReadLn(myFile, ligne);
    if Trim(ligne)='' then Continue;

    ParseLigne(ligne, nblumiere, cible, boutons);
    pressions := MinPressions(nblumiere, cible, boutons);

    if pressions<0 then
    begin
      Writeln('Erreur: configuration impossible ! Ligne = ', ligne);
      Halt(1);
    end;

    score := score + pressions;
  end;

  CloseFile(myFile);
  Solve:=score;
end;

begin
  elements := TStringList.Create;
  Writeln('Score : '+inttostr(Solve(nomfichier)));
  elements.Free;
end.
