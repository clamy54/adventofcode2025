{$mode objfpc}{$H+}
uses Sysutils, Classes, Z3Pas;

const nomfichier='input.txt';

type
  tableauint = array of LongInt;
  matrice = array of array of LongInt;

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
      begin
        subs:=subs+Input[a];
      end;
   end;
   Strings.Add(subs);
end;

procedure ParseLigne(ligne: string; var nbcompteur: Integer;
                    var cibles: tableauint; var boutons: matrice);
var
  a, b: Integer;
  partie, btn: string;
  debut, fin: Integer;
begin
  debut:=Pos('{', ligne);
  fin:=Pos('}', ligne);
  partie:=Copy(ligne, debut+1, fin-debut-1);
  Split(',', partie, elements);
  nbcompteur:=elements.Count;
  SetLength(cibles, nbcompteur);
  for a:=0 to nbcompteur-1 do
  begin
    cibles[a]:=StrToInt(Trim(elements[a]));
  end;
  Delete(ligne, debut, fin-debut+1);
  debut:=Pos('[', ligne);
  if debut>0 then
  begin
    fin:=Pos(']', ligne);
    Delete(ligne, debut, fin-debut+1);
  end;
  SetLength(boutons, 0);
  while True do
  begin
    debut:=Pos('(', ligne);
    if debut=0 then
    begin
      Break;
    end;
    fin:=Pos(')', ligne);
    if fin=0 then
    begin
      Break;
    end;
    btn:=Copy(ligne, debut+1, fin-debut-1);
    Delete(ligne, 1, fin);
    SetLength(boutons, Length(boutons)+1);
    SetLength(boutons[High(boutons)], nbcompteur);
    for a:=0 to nbcompteur-1 do
    begin
      boutons[High(boutons)][a]:=0;
    end;
    if btn<>'' then
    begin
      Split(',', btn, elements);
      for a:=0 to elements.Count-1 do
      begin
        b:=StrToInt(Trim(elements[a]));
        boutons[High(boutons)][b]:=1;
      end;
    end;
  end;
end;


function MinPressions(nbcompteur: Integer; const cibles: tableauint; const boutons: matrice): LongInt;
var
  opt: Optimize;
  varsb: array of Expr;
  somme: Expr;
  termes: array of Expr;
  a, b, nbboutons, nbtermes: Integer;
  resultat: z3_lbool;
  modele: Model;
  total: LongInt;
begin
  nbboutons:=Length(boutons);
  opt:=MkOptimize;
  SetLength(varsb, nbboutons);
  for a:=0 to nbboutons-1 do
  begin
    varsb[a]:=Int('b'+IntToStr(a));
    opt.Add(varsb[a]>=0);
  end;
  for a:=0 to nbcompteur-1 do
  begin
    nbtermes:=0;
    for b:=0 to nbboutons-1 do
    begin
      if boutons[b][a]=1 then
      begin
        inc(nbtermes);              
      end;
    end;
    if nbtermes=0 then
    begin
      if cibles[a]<>0 then        
      begin
        opt.Free;
        MinPressions:=-1;
        Exit;
      end;
    end
    else
    begin
      SetLength(termes, nbtermes);
      nbtermes:=0;
      for b:=0 to nbboutons-1 do
      begin
        if boutons[b][a]=1 then
        begin
          termes[nbtermes]:=varsb[b];
          inc(nbtermes);
        end;
      end;
      somme:=Sum(termes);
      opt.Add(Eq(somme, IntVal(cibles[a])));
    end;
  end;

  SetLength(termes, nbboutons);
  for a:=0 to nbboutons-1 do
  begin
    termes[a]:=varsb[a];
  end;
  somme:=Sum(termes);
  opt.Minimize(somme);

  resultat:=opt.Check;

  if resultat=L_TRUE then
  begin
    modele:=opt.Model;
    total:=0;
    for a:=0 to nbboutons-1 do
    begin
      total:=total+modele.ValueInt(varsb[a]);
    end;
    modele.Free;
    opt.Free;
    MinPressions:=total;
  end
  else
  begin
    opt.Free;
    MinPressions:=-1;
  end;
end;


function Solve(nom: string): LongInt;
var
  myFile: TextFile;
  ligne: string;
  nbcompteur: Integer;
  cibles: tableauint;
  boutons: matrice;
  pressions, score: LongInt;
begin
  AssignFile(myFile, nom);
  Reset(myFile);

  score:=0;

  while not EOF(myFile) do
  begin
    ReadLn(myFile, ligne);
    if Trim(ligne)='' then
    begin
      Continue;
    end;

    ParseLigne(ligne, nbcompteur, cibles, boutons);
    pressions:=MinPressions(nbcompteur, cibles, boutons);

    if pressions<0 then
    begin
      Writeln('Erreur: configuration impossible ! Ligne = ', ligne);
      Exit(-1);
    end;

    score:=score+pressions;
  end;

  CloseFile(myFile);
  Solve:=score;
end;

begin
  elements:=TStringList.Create;
  Writeln('Score : '+inttostr(Solve(nomfichier)));
  elements.Free;
end.
