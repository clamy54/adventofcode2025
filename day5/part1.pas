{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils; 

const nomfichier='input.txt';

type data=record
          min,max:int64;
     end;
     
var  liste: array of data;
     score,cpt,taille_liste:integer;
     elements,ingredients:TStringList;

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



procedure Charge(nom:string);
var myfile:TextFile;
    line:string;
    min,max:int64;
begin
  taille_liste:=0;
  AssignFile(myFile, nom);
  Reset(myFile);
  repeat
    ReadLn(myFile, line);
    if line<>'' then
    begin
        inc(taille_liste);
        SetLength(liste,taille_liste);
        split('-',line,elements);
        min:=StrToInt64(elements[0]);
        max:=StrToInt64(elements[1]);
        if min<max then
        begin
          liste[taille_liste-1].min:=min;
          liste[taille_liste-1].max:=max;
        end
        else
        begin
          liste[taille_liste-1].min:=max;
          liste[taille_liste-1].max:=min;
        end;
    end;
  until line='';
  repeat
    ReadLn(myFile, line);
    ingredients.Add(line);   
  until eof(myFile);
  Closefile(myfile);
end;


function teste(ingr:string):boolean;
var dummy:integer;
    valeur:int64;
begin
    valeur:=StrToInt64(ingr);
    teste:=false;
    for dummy:=0 to taille_liste-1 Do
    begin
        if (valeur>=liste[dummy].min) and (valeur<=liste[dummy].max) then
        begin
            teste:=true;
            break;
        end; 
    end;
end;

begin
    score:=0;
    ingredients:= TStringList.Create;
    elements := TStringList.Create;
    Charge(nomfichier);
    for cpt:=0 to ingredients.Count-1 do
    begin
        if teste(ingredients[cpt])=true then inc(score);
    end;
    Writeln('Score : '+inttostr(score));
    elements.free;
    ingredients.Free;

end.