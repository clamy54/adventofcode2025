{$mode objfpc}{$H+}
uses Sysutils, Classes, Crt, StrUtils,Math; 

const nomfichier='input.txt';

var myfile:TextFile;
    ligne:string;
    elements,couple: TStringList;
    cpt,dummy:integer;
    score,scoretmp:int64;

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


function teste(bas,haut:int64):int64;
var lg:integer;
    invalid,dummy,minpattern,maxpattern:int64;
begin
  teste:=0;
  for lg:=1 to 9 do
  begin
    minpattern:=10**(lg-1);
    maxPattern:=(10**lg)-1;
    //write('min : '+inttostr(minPattern)+' max : '+inttostr(maxPattern)+' : ');
    for dummy:=minPattern to maxPattern do
    begin
      invalid:=dummy*(10**lg)+dummy;
      if (invalid>=bas) and (invalid<=haut) then 
      begin
           teste:=teste+invalid;
           //write(inttostr(invalid)+' ');
      end;
      if invalid>haut then break;
    end;
  end;
  //writeln(teste);
end;


begin
    elements := TStringList.Create;
    couple:=TStringList.Create;
    AssignFile(myFile, nomfichier);
    Reset(myFile);
    readln(myFile, ligne);
    Closefile(myFile);
    score:=0;
    Split(',', ligne,elements);
    for dummy:=0 to elements.Count-1 Do
    begin
        Split('-', elements[dummy], couple);
        Write('Essai de l intervalle :' +couple[0]+' - '+couple[1]+' : ' );
        scoretmp:=teste(StrToInt64(couple[0]),StrToInt64(couple[1]));
        writeln(inttostr(scoretmp));
        score:=score+scoretmp;
    end;
    Writeln('Score : '+inttostr(score));
    couple.Free;
    elements.Free;

end.
