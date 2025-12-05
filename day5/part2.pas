{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils; 

const nomfichier='input.txt';

type data=record
          min,max:int64;
     end;
     
var  liste: array of data;
     i,j,taille_liste:integer;
     elements,ingredients:TStringList;
     score:int64;

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


procedure ajoute_liste(s:string);
var a,b:int64;
begin
  inc(taille_liste);
  SetLength(liste,taille_liste);
  split('-',s,elements);
  a:=StrToInt64(elements[0]);
  b:=StrToInt64(elements[1]);  
  if a<b then
  begin
    liste[taille_liste-1].min:=a;
    liste[taille_liste-1].max:=b;
  end
  else
  begin
    liste[taille_liste-1].min:=b;
    liste[taille_liste-1].max:=a;
  end;
end;

function teste(indexingr,indexliste:integer):boolean;
var t:integer;
    min,max,listemin,listemax:int64;

begin
  split('-',ingredients[indexingr],elements);
  min:=StrToInt64(elements[0]);
  max:=StrToInt64(elements[1]);   
  listemin:=liste[indexliste].min;
  listemax:=liste[indexliste].max;

  if (min>=listemin) and (max<=listemax) then
  begin
    ingredients.delete(indexingr);
    exit(true);
  end;

  if (min<listemin) and (max>listemax) then
  begin
    ingredients.delete(indexingr);
    if inttostr(min)<inttostr(listemin-1) then ingredients.add(inttostr(min)+'-'+inttostr(listemin-1)) else ingredients.add(inttostr(listemin-1)+'-'+inttostr(min));
    if inttostr(listemax+1)<inttostr(max) then ingredients.add(inttostr(listemax+1)+'-'+inttostr(max)) else ingredients.add(inttostr(max)+'-'+inttostr(listemax+1));
    exit(true);
  end;

  if (min<listemin) and (max>=listemin) and (max<=listemax) then
  begin
    ingredients.delete(indexingr);
    if inttostr(min)<inttostr(listemin-1) then ingredients.add(inttostr(min)+'-'+inttostr(listemin-1)) else ingredients.add(inttostr(listemin-1)+'-'+inttostr(min));
    exit(true);
  end;

  if (min>=listemin) and (min<=listemax) and (max>listemax) then
  begin
    ingredients.delete(indexingr);
    if inttostr(listemax+1)<inttostr(max) then ingredients.add(inttostr(listemax+1)+'-'+inttostr(max)) else ingredients.add(inttostr(max)+'-'+inttostr(listemax+1));
    exit(true);
  end;
  teste:=false;
end;



procedure Charge(nom:string);
var myfile:TextFile;
    line:string;
    a,b,min,max:int64;
    dummy:integer;
    tmp,cpt:int64;
    trigger:boolean;

begin
  taille_liste:=0;
  AssignFile(myFile, nom);
  Reset(myFile);
  repeat
    ReadLn(myFile, line);
    if line<>'' then
    begin
      if taille_liste=0 then ajoute_liste(line) else
      begin
        ingredients.Clear;
        ingredients.add(line);
        Writeln('ligne de depart : '+line);
        repeat
            trigger:=false;
            for dummy:=0 to taille_liste-1 Do
            begin
              if ingredients.count>0 then
                begin
                for cpt:=0 to ingredients.count-1 Do
                begin
                  trigger:=teste(cpt,dummy);
                  if trigger=true then break;
                end;
                if trigger=true then break;
              end;  
            end;
        until trigger=false;
        ingredients.Sorted:=true;
        Writeln('ligne d arrivee : ');
        for dummy:=0 to ingredients.count-1 Do 
        begin 
         ajoute_liste(ingredients[dummy]);
         Writeln(ingredients[dummy]);
        end;
        ingredients.Sorted:=false;
      end;
    end;
  until line='';
  Closefile(myfile);
end;

begin
    ingredients:= TStringList.Create;
    ingredients.Sorted:=false;
    ingredients.Duplicates:=dupIgnore;
    elements := TStringList.Create;
    Charge(nomfichier);
    score:=0;
    for i:=0 to taille_liste-1 do
      score:=score+(liste[i].max-liste[i].min+1);


    Writeln('Score : '+inttostr(score));
    elements.free;
    ingredients.Free;

end.