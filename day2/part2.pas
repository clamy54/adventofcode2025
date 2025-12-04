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
var rp,quotient,lg:integer;
    invalid,t,dummy,minpattern,maxpattern,patternencours:int64;
    chaine:string;
    slice: TStringList;
begin
  slice := TStringList.Create;
  slice.Sorted := true;
  slice.Duplicates := dupIgnore; 
  teste:=0;
  minpattern:=length(inttostr(bas));
  maxpattern:=length(inttostr(haut));
  for patternencours:=minPattern to maxpattern do
  begin
    Write('pattern en cours : '+inttostr(patternencours)+' ');
    for quotient:=2 to patternencours do
    begin
      Write('quotient : '+inttostr(quotient)+' - ');
      if (patternencours mod quotient=0) then
      begin
        for dummy:=10**((patternencours DIV quotient)-1) to (10**((patternencours DIV quotient)))-1 do
        begin
          chaine:='';
          for t:=1 to quotient do chaine:=chaine+inttostr(dummy);
          invalid:=StrToInt64(chaine);
          if slice.IndexOf(chaine) = -1 then
          begin
            if (invalid>=bas) and (invalid<=haut) then
            begin
              slice.Add(chaine);
              write(inttostr(invalid)+' ');
              teste:=teste+invalid; 
            end;
          end;
          if invalid>haut then break;
        end;
      end;
    end;
    writeln();
  end;
  writeln();
  slice.Free;
  //readln();
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
        writeln(' -  Score : '+inttostr(scoretmp));
        score:=score+scoretmp;
    end;
    Writeln('Score : '+inttostr(score));
    couple.Free;
    elements.Free;

end.
