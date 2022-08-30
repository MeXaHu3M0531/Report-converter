unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  fileutil, windows, Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Menus, ComCtrls, Grids,
  DebenuPDFLibrary64AX1811_18_11_TLB, MMSystem, LazUtf8, LazFileUtils;

type
    dat = record
      x:string[100];
      tex:string[100];
      probel:integer;
      stolb:integer;
      limitmax:boolean;
      limitmin:boolean;
      vlevo:integer;
      time:boolean;
      propusk:integer;
      checked:boolean;
      stroka:boolean;
      endOfTabl:string[50];  //4 свойства
      end;
    porog=record
      typ:byte;
      min:real;
      max:real;
      time:integer;
      nachalo_v_texte:integer;
      nomer:integer;
    end;
    testrecord=record
      flag:boolean;
      id:string[20];
      interval:boolean;
      positions:boolean;
      etal_pos:integer;
      pos:integer;
      punkt_v_tabl:string[50];
    end;

  { TForm1 }

  TForm1 = class(TForm)
    AxcPDFLibrary1: TAxcPDFLibrary;
    NewCopyBox: TCheckBox;
    OpenDialog2: TOpenDialog;
    Test: TButton;
    Button2: TButton;
    Testing: TCheckBox;
    CopyNastr: TMenuItem;
    MenuItem2: TMenuItem;
    report_type: TMenuItem;
    OpenDialog1: TOpenDialog;
    SvalkaBox: TCheckBox;
    Sek: TLabel;
    Minut: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    KonverBase: TMenuItem;
    RazrabMode: TMenuItem;
    ProgressBar1: TProgressBar;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    Timer1: TTimer;
    SekTimer: TTimer;
    MinTimer: TTimer;
    procedure TestClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TestingChange(Sender: TObject);
    procedure CopyNastrClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KonverBaseClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure report_typeClick(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MinTimerTimer(Sender: TObject);
    procedure RadioButton2Change(Sender: TObject);
    procedure SekTimerTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  t:textfile;
  f:file of dat;
  a:array[1..10] of string;
  c:array[1..10] of byte;
  b:array[1..150] of dat;
  minyti,sekundi:integer;
  solve:string;
  savedir:string;
  SysDisks: set of 0..25;
  NewDisks:array[0..5] of integer;
  PDFLibrary: IPDFLibrary;
  UnlockResult:integer;
  copy:boolean;
implementation
function erase_test(testingrec:testrecord):testrecord;
begin
  with  testingrec do
    begin
      flag:=false;
      id:='';
      interval:=false;
      positions:=false;
      etal_pos:=0;
      pos:=0;
      punkt_v_tabl:='';
    end;
end;
function sbros_poroga(p:porog):porog;
begin
  with p do
    begin
      typ:=0;
      min:=0;
      max:=0;
      time:=0;
      nachalo_v_texte:=0;
      nomer:=0;
    end;
end;
function Data(s:string):string;
var z1,z2:string;
  i,j:integer;
begin
  {02/07/21  15:04:04 -> 2021-07-02 15:04}
  i:=1;
  j:=1;
 // showmessage('"'+s+'"');
  z1:='';
  z2:='';
  if length(s)>0 then
  if pos('-',s)=0 then
  begin
  if ((s<>'') and (s<>' ') and (s<>'-')) then
    begin
      while s[i]<>' ' do
        begin
          z1:=z1+s[i];
          i:=i+1;
        end;
      while s[i]=' ' do
        i:=i+1;
      for j:=0 to 4 do
      z2:=z2+s[i+j];
    //z1:='20'+z1;
      for j:=1 to length(z1) do
        if z1[j]='/' then
          z1[j]:='-';
      z1:=z1[7]+z1[8]+z1[6]+z1[4]+z1[5]+z1[3]+z1[1]+z1[2];
      z1:='20'+z1;
      data:=z1+' ' +z2;
 // showmessage(data);
    end;
  end
  else
  data:='-';
end;
function SbrosD(d:dat):dat;
begin
 with d do          //сброс d
               begin
                 //showmessage('');
          x:='';
          tex:='';
          probel:=0;
          vlevo:=0;
          time:=false;
          stolb:=0;
          propusk:=0;
          stroka:=false;
          limitmax:=false;
          limitmin:=false;
          checked:=false;
          endOfTabl:='';
        end;

 SbrosD:=d;
end;
function Check_porog_time(m:string; l:integer):string;//Функция возвращает время за пределами порога для времени, или прочерк для единоразового
var i,j:integer;
  s:string;
begin
  i:=0;
  while m[l+i]<>' ' do
    i:=i+1;
  while m[l+i]=' ' do
    i:=i+1;
  s:='';
  if m[l+i]='-' then
    check_porog_time:='-'
  else
    begin
    while m[l+i]<>' ' do
      begin
        s:=s+m[l+i];
        i:=i+1;
      end;
    Check_porog_time:=s;
    end;

end;
function propusk_stolb(m:string; l,i:integer):integer;
var  j,k:integer;
begin
  j:=0;
  for k:=1 to i do
    begin
      while m[l+j]<>' ' do
        j:=j+1;
      while m[l+j]=' ' do
        j:=j+1;
    end;
  propusk_stolb:=l+j;
end;
function find_temp(m:string;l:integer):string;   //функция возвращает температуру по первому символу у порога
var i,j:integer;
  k:string;
begin
  j:=0;
  while m[l-j]<>' ' do
    begin
      j:=j+1;
    end;
  while m[l-j]=' ' do
    j:=j+1;
  while m[l-j]<>' ' do
    j:=j+1;
  j:=j-1;
  k:='';
  while m[l-j]<>' ' do
    begin
    k:=k+m[l-j];
    j:=j-1;
    end;
  find_temp:=k;
end;
function find_next_porog(m,s1,s2:string):integer;   //функция возвращает номер первого символа следующий порог, в котором не меняли первую букву
var nomer1,nomer2:integer;
begin
  nomer1:=pos(s1,m);
  nomer2:=pos(s2, m);
  if ((nomer1 = 0) and (nomer2=0)) then
    find_next_porog:=0;
  if ((nomer1 = 0) and (nomer2<>0)) then
    find_next_porog:=nomer2;
  if ((nomer1 <> 0) and (nomer2=0)) then
    find_next_porog:=nomer1;
  if ((nomer1 <> 0) and (nomer2<>0)) then
    begin
      if nomer1<nomer2 then
        find_next_porog:=nomer1
      else
        find_next_porog:=nomer2;
    end;
end;
function text_and_probels(m:string;l,i:integer):string;
var j,k:integer;
  s:string;
begin
 j:=0;
 s:='';
 k:=i;
  while k>=0 do
    begin
      while m[l+j]=' ' do
        begin
        s:=s+m[l+j];
        j:=j+1;
        end;
      while ((m[l+j]<>' ') and (m[l+j]<>#13)) do
        begin
          s:=s+m[l+j];
          j:=j+1;
        end;
      k:=k-1;

    end;
 text_and_probels:=s;
end;

{$R *.lfm}

{ TForm1 }

procedure TForm1.TestClick(Sender: TObject);
var
i,k,l,h,y,j,g: Integer;
q,s,m,z:string;
d:dat;

begin
  //showmessage


PDFLibrary := CoPDFLibrary.Create;
UnlockResult := PDFLibrary.UnlockKey('jw68e4dk8u79p79oo4dy3oo3y');
if UnlockResult = 1 then
begin
q:='Test.PDF';

PDFLibrary.LoadFromFile(widestring(q), '');
//showmessage(inttostr(PDFLibrary.pageCount));
assignfile(t,'log.txt');
rewrite(t);
for i:=1 to  PDFLibrary.pageCount do
begin
PDFLibrary.SelectPage(i);
m:=PDFLibrary.getpagetext(7);
writeln(t,m)
{for j:=0 to k do
begin
  if not(b[j].checked) then
  begin
  y:=pos(b[j].x, m);
  if (y<>0) then
    begin
      d:=b[j];
      s:='';
      b[j].checked:=true;
      l:=y+length(d.x);
      if d.propusk<>0 then
        for h:=1 to d.propusk do
            begin
           // z:='';
           // for g:=-100 to 100 do
            //  z:=z+m[l+g];
           // showmessage(z);
            //showmessage(b[j].x);
            //showmessage(m[y-length(d.x)]);
            while (m[l])<>utf8string(#13) do
            begin
              l:=l+1;
              //showmessage(utf8string('"' +m[l-5]+ m[l-4]+m[l-3]+m[l-2]+m[l-1]+ m[l]+m[l+1]+m[l+2]+m[l+3]+m[l+4]+'"'));
             // showmessage(inttostr(word(m[l])));
              end;
            l:=l+2;
            while m[l]=' ' do
              l:=l+1;
            end;

      if d.stolb<>0 then
        for h:=1 to d.stolb do
          begin
            while m[l]<>' ' do
              l:=l+1;
            while m[l]=' ' do
              l:=l+1;
          end;

      repeat
        if (m[l]=' ') then
          begin
          d.probel:=d.probel-1;
          s:=s+m[l];
          l:=l+1;
          end;
        while ((m[l]<>' ' ) and (m[l]<>#13)) do
          begin
        s:=s+m[l];
      // if m[l]=#13 then showmessage('"' + m[l] + '"');
        l:=l+1;

          end;

      until (d.probel=0);
     // showmessage('"'+d.tex+'"'+'+'+'"'+s+'"');
       showmessage(d.tex+s);
      //showmessage(inttostr(word(m[l])));
    end;
  end;
end;}
end;
//closefile(t);
end else
begin
ShowMessage('Invalid license key');
end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var searchResult : TSearchRec;
//PDFLibrary: IPDFLibrary;
i,k,l,h,y,j,g,kolvo,setik,stran,startoftabl,r,testint,dlina_m, tabl_i, tabl_j,stolb_count,jorj: longint;
q,s,m,z,z1,z2,z3,teststring,endtabl:string;
d:dat;
etalon_position,etalon_interval,test_position,test_interval,test_nomer, warning_nomer:integer;
test_id,test_stroka:string;
tabl:boolean;
mass: array[1..10,1..500] of string;
buf:string;
mas_porog:array[1..8] of porog;
flag_of_LimitMin,flag_of_LimitMax:boolean;
test_array:array[1..10000] of testrecord;   //массив с инфой о всех ошибках
mass_warnings:array[1..10000] of integer;   //массив с инфой о номерах проблемных файлов
testfile:textfile;
test_pred:string;
int_pred,int_nast:integer;
int_nomer_poroga_v_texte,int_nomer_poroga:integer;
limitmin,limitmax:string;
limit_extra_min,limit_extra_max:real;
buf1, buf2:string;
int_buf:integer;
pdfname:string;
newtextfile:textfile;
stringfromtxt:string;
errorfile:textfile;
begin
  if NewCopyBox.checked then
         begin
           if SelectDirectoryDialog1.Execute then
           begin
             assignfile(newtextfile,'newtextfile.txt');
             reset(newtextfile);
             assignfile(errorfile,'errorfile.txt');
             rewrite(errorfile);
             assignfile(f, 'base.dat');
             reset(f);
             read(f,d);
             savedir:=d.x;
             i:=0;
             while not(eof(newtextfile)) do
             begin
               readln(newtextfile,stringfromtxt);
               if ((stringfromtxt[length(stringfromtxt)]<'0') or (stringfromtxt[length(stringfromtxt)]>'9')) then
                 delete(stringfromtxt,1,2);
               pdfname:='\*'+stringfromtxt+'*.pdf';
               if FindFirst(SelectDirectoryDialog1.FileName+pdfname, faAnyFile, searchResult) = 0 then
               begin
                 q:=SelectDirectoryDialog1.FileName +'\' +searchResult.name;
                 if not(fileutil.CopyFile((q),(savedir+searchresult.name),true)) then
                   showmessage('Copy error at '+searchResult.name+ '. Error code:' + IntToStr(GetLastError)+'; "'+q+'" -> '+'" '+savedir+searchresult.name+' "')
                 else
                   i:=i+1;
               findclose(searchResult);
               end
               else
               begin
                 showmessage('Can not find ' + stringfromtxt);
                 //writeln(errorfile,stringfromtxt);
               end
             end;
             closefile(f);
            // showmessage(inttostr(i));
             closefile(errorfile);
             closefile(newtextfile);
           end;
         end
    else
  if RadioButton1.checked then
    begin

      if SelectDirectoryDialog1.Execute then
        begin
          kolvo:=0;
          if FindFirst(SelectDirectoryDialog1.FileName+'\*.pdf', faAnyFile, searchResult) = 0 then
              begin
                repeat
                kolvo:=kolvo+1;
                until FindNext(searchResult) <> 0;
              end;
          Findclose(searchResult);
         // showmessage(inttostr(kolvo));

          if FindFirst(SelectDirectoryDialog1.FileName+'\*.pdf', faAnyFile, searchResult) = 0 then
           begin
             {SekTimer.enabled:=true;
             MinTimer.enabled:=true;

             Sek.caption:='0';
             Minut.caption:='0';
             Sek.visible:=true;
             Minut.visible:=true;  }
             setik:=0;
             LimitMin:='';
             LimitMax:='';
             test_position:=0;
             test_nomer:=0;
             warning_nomer:=0;
             int_nomer_poroga:=0;
             flag_of_limitmax:=false;
             flag_of_limitmin:=false;
             Limit_extra_Min:=10000;
             Limit_extra_Max:=-10000;
             ProgressBar1.visible:=true;
             assignfile(f, 'base.dat');
             reset(f);
             read(f,d);
             etalon_position:=filesize(f)-2;
             if testing.checked then
               begin
                 assignfile(testfile,'Convertation report.txt');
                 rewrite(testfile);
               end;
             savedir:=d.x;
             //with d do          //сброс d
             d:=sbrosD(d);
             for i:=1 to 10000 do
               test_array[i]:=erase_test(test_array[i]);
            // PDFLibrary := CoPDFLibrary.Create;
             //UnlockResult := PDFLibrary.UnlockKey('jw68e4dk8u79p79oo4dy3oo3y');
             if SvalkaBox.checked then
              begin
               assignfile(t, savedir+'svalka.txt');
               rewrite(t);
              end;

             tabl:=false;
             for k:=1 to (filesize(f)-1) do
               begin
                 seek(f,k);
                 read(f,d);
                 b[k]:=d;
               end;
             end;
             if UnlockResult = 1 then
             repeat
                            test_position:=0;
                             test_nomer:=0;
                             int_nomer_poroga:=0;
             warning_nomer:=0;
             test_pred:='';
             flag_of_limitmax:=false;
             flag_of_limitmin:=false;
             Limit_extra_Min:=10000;
             Limit_extra_Max:=-10000;
               q:=SelectDirectoryDialog1.FileName+'\'+searchResult.name;
               PDFLibrary.LoadFromFile(widestring(q), '');
               //showmessage(q);
               j:=1;
               while ( (j<length(q)-3)) do
                 begin
                   if q[j]='\' then
                     s:=''
                   else
                     s:=s+q[j];
                   j:=j+1;
                 end;
               //showmessage(savedir+s);
               if not(SvalkaBox.checked) then
               begin
               assignfile(t,savedir+s+'.txt');
               rewrite(t);
               if testing.checked then
                 begin
                  test_nomer:=test_nomer+1;
                  test_array[test_nomer].id:=s;
                  test_array[test_nomer].etal_pos:=etalon_position;
                 end;
               end;
             //  showmessage(inttostr(PDFLibrary.pageCount));
               //showmessage(q);
               for j:=1 to k do
                 b[j].checked:=false;
               if not(SvalkaBox.checked) then
                 stran:=PDFLibrary.pageCount
               else
                 stran:=1;
               tabl:=false;
               for i:=1 to  stran do
                 begin
                 PDFLibrary.SelectPage(i);
                 m:=PDFLibrary.getpagetext(7);
                 //showmessage(m);
               // if not(flag_of_limitmax and flag_of_limitmin) then
                if not(tabl) then
                 for j:=1 to k do
                   begin
                     //if d.x:'' then
                     if not(b[j].checked) then
                       begin
                 y:=pos(b[j].x, m);
                   if (y<>0) then
                       begin
                         d:=sbrosD(d);
                         d:=b[j];
                         s:='';
                         b[j].checked:=true;
                         l:=y+length(d.x);
                     if d.limitmin then
                     begin
                       flag_of_limitmin:=true;
                       limitmin:=d.x;
                     end;
                     if d.limitmax then
                     begin
                       flag_of_limitmax:=true;
                       limitmax:=d.x;
                     end;

                     if d.propusk<>0 then
                       for h:=1 to d.propusk do
                           begin
                           while (m[l])<>utf8string(#13) do
                           begin
                             l:=l+1;
                             //showmessage(utf8string('"' +m[l-5]+ m[l-4]+m[l-3]+m[l-2]+m[l-1]+ m[l]+m[l+1]+m[l+2]+m[l+3]+m[l+4]+'"'));
                            // showmessage(inttostr(word(m[l])));
                             end;
                           l:=l+2;
                           while m[l]=' ' do
                             l:=l+1;
                           end;
                     if d.vlevo<>0 then
                       begin
                         for h:=1 to d.vlevo do
                           begin
                             while m[l]=' ' do
                               l:=l-1;
                             while m[l]<>' ' do
                               l:=l-1;
                             while m[l]=' ' do
                               l:=l-1;
                             while m[l]<>' ' do
                               l:=l-1;
                             l:=l+1;
                           end;
                       end;
                     if d.stolb<>0 then
                       for h:=1 to d.stolb do
                         begin
                           while m[l]<>' ' do
                             l:=l+1;
                           while m[l]=' ' do
                             l:=l+1;
                         end;
                     if d.endOfTabl<>'' then
                       begin
                       tabl:=true;
                       startoftabl:=y;
                       endtabl:=d.endOfTabl;
                       b[j].checked:=false
                      { teststring:='';
                       for r:=-10 to 1000 do
                         teststring:=teststring+m[l+r];
                       showmessage(teststring);
                       teststring:='';
                       //showmessage(m);
                      // showmessage(d.x);
                       z:='';     }
                       end
                     else
                     if not (flag_of_limitmin or flag_of_limitmax) then

                     begin                //запись с учетом probel
                     if m[l+1]<>'-' then
                     repeat
                       if (m[l]=' ') then
                         begin
                         d.probel:=d.probel-1;
                         s:=s+m[l];
                         l:=l+1;
                         end;
                       while ((m[l]<>' ' ) and (m[l]<>#13)) do
                         begin
                       s:=s+m[l];
                     // if m[l]=#13 then showmessage('"' + m[l] + '"');
                       l:=l+1;

                         end;

                     until (d.probel=0)
                     else
                       s:=m[l];
                     end;
                     if d.time then
                       if m[l+1]<>'-' then
                       s:=data(s)
                       else
                       s:='-';
                     //  b[j]
                //    showmessage('"'+d.tex+'"'+'+'+'"'+s+'"');
                      //showmessage(d.tex+s);
                      if not(tabl or (flag_of_limitmin or flag_of_limitmax)) then
                        begin

                        if d.stroka then
                        begin
                          write(t,d.tex+s+', ');
                          test_position:=test_position+1;
                        end
                        else
                        begin
                          writeln(t,d.tex+s);
                          //test_position:=test_position+1;
                          if testing.checked then
                          begin
                            if pos('Logging Interval',d.tex+s)<>0 then
                              etalon_interval:=strtoint(s);
                            test_position:=test_position+1;
                          end;
                        //  showmessage(d.tex+s);
                        end
                        end;
                      if (flag_of_limitmin and flag_of_limitmax) then
                      begin
                        flag_of_limitmin:=false;
                        test_position:=test_position+2;
                        flag_of_limitmax:=false;
                        int_nomer_poroga_v_texte:=find_next_porog(m,limitmin,limitmax);
                        int_nomer_poroga:=int_nomer_poroga+1;
                        writeln(t,' Alarms');

                        while int_nomer_poroga_v_texte<>0 do
                          begin
                            writeln(t,'  '+inttostr(int_nomer_poroga)+': ');
                            if Check_porog_time(m,int_nomer_poroga_v_texte)='-' then
                              write(t,'Single event: ')
                            else
                              write(t,'Accumulated: ');
                            buf1:=find_temp(m,int_nomer_poroga_v_texte);
                            buf1[pos('.',buf1)]:=',';
                            //showmessage(buf1);
                            buf2:='';
                            for int_buf:=0 to 20 do
                              buf2:=buf2+m[int_nomer_poroga_v_texte+int_buf];
                            // showmessage(m[int_nomer_poroga_v_texte]+m[int_nomer_poroga_v_texte+1]+m[int_nomer_poroga_v_texte+2]+m[int_nomer_poroga_v_texte+3]+m[int_nomer_poroga_v_texte+4]+m[int_nomer_poroga_v_texte+5]+m[int_nomer_poroga_v_texte+6]+m[int_nomer_poroga_v_texte+7]+m[int_nomer_poroga_v_texte+8]+m[int_nomer_poroga_v_texte+9]+m[int_nomer_poroga_v_texte+10]);
                            if pos(limitmin,buf2)<>0 then
                            begin
                              write(t,'bellow T=');
                              if strtofloat(buf1)<limit_extra_min then
                                limit_extra_min:=strtofloat(buf1);
                            end;
                            if pos(limitmax,buf2)<>0 then
                              begin
                              write(t,'above T=');
                              if strtofloat(buf1)>limit_extra_max then
                                limit_extra_max:=strtofloat(buf1);
                              end;
                            buf1:='';
                            buf2:='';
                            int_buf:=0;
                            write(t,find_temp(m,int_nomer_poroga_v_texte));
                            if Check_porog_time(m,int_nomer_poroga_v_texte)<>'-' then
                              writeln(t,' for ' + Check_porog_time(m,int_nomer_poroga_v_texte))
                            else
                              writeln(t,' ');
                            write(t,'Status: ');
                            writeln(t,text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,2),0));

                            if data(text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,3),1))<>'-' then
                            begin
                            write(t, 'Date and time of alarm: ');
                            writeLn(t, data(text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,3),1)));
                            write(t,'Time elapsed from start to alarm: ');
                            writeln(t,text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,5),0));
                            write(t,'Total Number of exits beyond the threshold: ');
                            writeln(t,text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,6),0));
                            write(t,'Maximum time of exceeding the threshold value: ');
                            writeln(t,text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,7),0));
                            write(t,'Total time beyond thee threshold value: ');
                            writeln(t,text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,8),0));
                            end;
                            writeLn(t,' ');
                            m[int_nomer_poroga_v_texte]:='1';
                            int_nomer_poroga:=int_nomer_poroga+1;

                            int_nomer_poroga_v_texte:=find_next_porog(m,limitmin,limitmax);
                           // showmessage(inttostr(int_nomer_poroga_v_texte));
                          end;

                        //writeLn(t,'something about limits');
                      end
                     // showmessage(d.tex+s);
                     //showmessage(inttostr(word(m[l])));
                     end

                   else
                     begin
                       if (b[j].x='*') then
                         begin
                        //   showmessage(d.x);
                           b[j].checked:=true;
                           writeln(t,b[j].tex);
                           test_position:=test_position+1;
                         end;
                 end;
                     end;
                     end;

                if tabl then
                  begin
               //   showmessage('Start tabl');
                  l:=startoftabl;
                  for h:=1 to 2 do
                    begin
                      while (m[l])<>utf8string(#13) do
                        begin
                          l:=l+1;
                             //showmessage(utf8string('"' +m[l-5]+ m[l-4]+m[l-3]+m[l-2]+m[l-1]+ m[l]+m[l+1]+m[l+2]+m[l+3]+m[l+4]+'"'));
                            // showmessage(inttostr(word(m[l])));
                        end;
                        l:=l+2;

                        while m[l]=' ' do
                          l:=l+1;
                        end;
                      s:='';
                   //   showmessage('');
                     // testint:=0;
                     for tabl_i:=1 to 6 do
                       for tabl_j:=1 to 500 do
                         mass[tabl_i,tabl_j]:='';
                     tabl_i:=0;
                     tabl_j:=1;
                     //if
                     begin
                     stolb_count:=1;
                     while pos(m[l+h],solve)<>0 do
                           h:=h+1;
                     while m[l+h]<>#13 do
                       begin
                         while pos(m[l+h],solve)=0 do
                           h:=h+1;
                         while pos(m[l+h],solve)<>0 do
                           h:=h+1;
                         stolb_count:=stolb_count+1;
                       end;
                     stolb_count:=stolb_count div 3;
                     h:=0;
                     end;
                     z1:='';
                     z2:='';
                     z3:='';
                     z:='';
                     s:='';
                  //   showmessage(inttostr(stolb_count));
                      while (pos(d.endoftabl,z)=0) do
                        begin
                          if length(z)>0 then
                          begin
                          z1:=data(z1);
                          if length(z3)>0 then
                          begin
                           buf:=z3;
                          buf[pos('.',buf)]:=',';
                          if ((Limit_extra_Min=10000) and (Limit_extra_Max=-10000)) then
                            z3:=z3+' x'
                          else
                            begin
                         //   showmessage(z3+'/'+buf+floattostr(Limit_extra_Min)+'/'+floattostr(Limit_extra_Max));
                          if ((strtofloat(buf)>=Limit_extra_Min) and (strtofloat(buf)<=Limit_extra_Max)) then
                            z3:=z3+' Ok'
                          else
                            z3:=z3+' x';
                          end;
                          end;
                          z:=z1+' ' +z3;
                          { teststring:='';
                          for r:=0 to 1000 do
                         teststring:=teststring+m[l+r];
                       showmessage(teststring);
                       teststring:=''; }
                          s:=s+z;
                          end;
                         // showmessage(z);

                          {testint:=testint+1;
                          if testint>(700*2.28) then
                          begin
                            teststring:='';
                            for r:=0 to 100 do
                            teststring:=teststring+m[l+r];
                               showmessage(teststring);
                            teststring:='';
                          end;}
                        //  showmessage(z);
                          if length(z)>0 then
                          begin
                          if (pos(z[7],solve)<>0)then
                            begin
                              tabl_i:=tabl_i+1;
                              if tabl_i>stolb_count then
                                begin
                                  tabl_i:=1;
                                  tabl_j:=tabl_j+1;
                                end;
                              mass[tabl_i,tabl_j]:=z;
                             // showmessage(mass[tabl_i,tabl_j]+' ['+inttostr(tabl_i)+','+inttostr(tabl_j)+']');
                           end;
                          end;
                         // else
                         teststring:='';
                         for jorj:=-10 to 0 do
                           teststring:=teststring+m[l+jorj];
                         //showmessage(teststring);
                          if pos(#10,teststring)<>0 then
                          begin
                            stolb_count:=1;
                            while pos(m[l+h],solve)<>0 do
                             h:=h+1;
                            while m[l+h]<>#13 do
                              begin
                              while pos(m[l+h],solve)=0 do
                                h:=h+1;
                              while pos(m[l+h],solve)<>0 do
                                h:=h+1;
                              stolb_count:=stolb_count+1;
                              end;
                          stolb_count:=stolb_count div 3;
                       //  if stolb_count>6 then showmessage(inttostr(stolb_count));
                          h:=0;
                          end;
                          z:='';
                          z1:='';
                          z2:='';
                          z3:='';
                          dlina_m:=length(m);
                         // if (l<length(m)) then
                          while ((pos(m[l],solve+d.endoftabl)<>0) ) do
                            begin
                              z1:=z1+m[l];
                              l:=l+1;
                            end;
                          h:=0;
                         // if ((l+h)<length(m)) then
                          while ((pos(m[l+h],solve+d.endoftabl)=0) and(h<10)) do
                            begin
                              h:=h+1;
                            end;
                          if (h<5) then
                          begin
                            l:=l+h;
                          //  if length(m)>0 then
                        //  if (l<length(m)) then
                            while ((pos(m[l],solve+d.endoftabl)<>0) ) do
                              begin
                            z2:=z2+m[l];
                            l:=l+1;
                              end;
                          end;
                          h:=0;
                        //  if ((l+h)<length(m)) then
                          while ((pos(m[l+h],solve+d.endoftabl)=0) and (h<5)) do
                            begin
                              h:=h+1;
                            end;
                          if (h<5) then
                          begin
                            l:=l+h;
                          //  if (l<length(m)) then
                             while ((pos(m[l],solve+d.endoftabl)<>0)) do
                              begin
                            z3:=z3+m[l];
                            l:=l+1;
                              end;
                          end;
                          z1:=z1+' '+z2;
                          z:=z1+' '+z3;

                         // showmessage(z1);
                          //showmessage(z2);
                          //showmessage(z3);
                         // showmessage(z);
                        //  if (l<length(m)) then
                          while ( (pos(m[l],solve+d.endoftabl)=0) and (l<length(m)) ) do
                            l:=l+1;
                          //showmessage(s);
                        end;
                      z:='';
                      tabl:=false;
                      tabl_i:=1;
                      h:=1;
                      while mass[tabl_i,h]<>'' do
                       begin
                         h:=1;
                        // if h<7 then
                         while (h<=tabl_j) do
                          begin

                           if length(mass[tabl_i,h])>21 then
                           begin
                             writeln(t,mass[tabl_i,h]);
                           //etalon_interval
                           if ((testing.checked) and (test_pred<>''))  then
                             begin
                       //      showmessage(mass[tabl_i,h]);
                       //      showmessage(mass[tabl_i,h][15]+mass[tabl_i,h][16]);
                             int_nast:=strtoint(mass[tabl_i,h][15]+mass[tabl_i,h][16]);
                             int_pred:=strtoint(test_pred[15]+test_pred[16]);
                               if not((int_nast-int_pred=etalon_interval) or (int_nast-int_pred=etalon_interval-60)) then
                                 begin
                               //  showmessage(inttostr(int_nast-int_pred));
                               //  showmessage(inttostr(int_nast-int_pred)+' '+test_array[test_nomer].id+' ' +mass[tabl_i,h] +' - ' + test_pred);
                                   if not(test_array[test_nomer].flag) then
                                     warning_nomer:=warning_nomer+1;
                                   test_array[test_nomer].flag:=true;
                                   test_array[test_nomer].interval:=true;
                                   mass_warnings[warning_nomer]:=test_nomer;
                                   test_array[test_nomer].punkt_v_tabl:=mass[tabl_i,h];
                                 end;

                             end;
                           test_pred:=mass[tabl_i,h];
                           end;
                           //if (strtoint(mass[tabl_i,h][15]+mass[tabl_i,h][16])
                           h:=h+1;
                        //   showmessage(mass[tabl_i,h]);
                           end;
                         tabl_i:=tabl_i+1;
                         h:=1;
                       end;
                     { for tabl_i:=1 to 6 do
                        for h:=1 to tabl_j do
                         // if pos
                          writeln(t, mass[tabl_i,h]);}

                  end;

               if testing.checked then
                 begin
                   test_array[test_nomer].pos:=test_position;
                 end;

               if not(SvalkaBox.checked) then

               end;
               if testing.checked then
                 begin
                   if test_position<>etalon_position then
                     begin
                       if not(test_array[test_nomer].flag) then
                         warning_nomer:=warning_nomer+1;
                       test_array[test_nomer].flag:=true;
                      // showmessage('');
                       test_array[test_nomer].positions:=true;
                       mass_warnings[warning_nomer]:=test_nomer;
                     end;
                 end;
               if not(svalkabox.checked) then
                 closefile(t);
               setik:=setik+1;
               ProgressBar1.position:=round(100*(setik/kolvo));
             until FindNext(searchResult) <> 0;
             closefile(f);
           end;


    SekTimer.enabled:=false;
    MinTimer.enabled:=false;
    if testing.checked then
      begin
        if warning_nomer=0 then
          writeln(testfile,'There are no warnings!')
        else
          begin
            for i:=1 to warning_nomer do
              begin
              write(testfile,('Warning! '+test_array[mass_warnings[i]].id+' is invalid with '));
              if test_array[mass_warnings[i]].positions then
                write(testfile,'positions on title:' + inttostr(test_array[mass_warnings[i]].pos)+'/'+inttostr(test_array[mass_warnings[i]].etal_pos)+'; ');
              if test_array[mass_warnings[i]].interval then
                write(testfile,'interval in table in string: '+test_array[mass_warnings[i]].punkt_v_tabl);
              writeln(testfile,'');
              end
          end
      end;
    if SvalkaBox.checked then
    closefile(t);
    if testing.checked then
      closefile(testfile);
    ProgressBar1.visible:=false;
    ProgressBar1.position:=0;
    end
  else
    begin
      if not(timer1.enabled) then
      begin
        //online:=true;
        showmessage('Before starting, please remove the Loggers from the computer');
        timer1.enabled:=true;
        Button2.caption:='Stop conversion';
        integer(SysDisks) := GetLogicalDrives;
        for j:=0 to 5 do
          NewDisks[j]:=-1;
      end
      else
       // online:=false;
       timer1.enabled:=false;
        Button2.caption:='Start conversion';
    end;
end;

procedure TForm1.TestingChange(Sender: TObject);
begin

end;

procedure TForm1.CopyNastrClick(Sender: TObject);
begin
  copy:=not(copy);
  if copy then
    begin
      CopyNastr.caption:='The reports are copied from USB and converted. Click to change.';
    end
  else
    begin
      CopyNastr.caption:='Reports from USB are converted. Click to change.';
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
s:string;
d:dat;
begin
  copy:=true;
  a[1]:=widestring('probel');
  a[2]:=widestring('stolb');
  a[3]:=widestring('propusk');
  a[4]:=widestring('endOfTabl');
  a[5]:=widestring('vlevo');
  a[6]:=widestring('data');
  a[7]:=widestring('stroka');
  a[8]:=widestring('limitmin');
  a[9]:=widestring('limitmax');
  for i:=1 to 10 do
    c[i]:=length(a[1]);
  solve:='0123456789/:.';
  //notsolve:=' ' + #13 +#10
  //online:=false;
  PDFLibrary := CoPDFLibrary.Create;
  UnlockResult := PDFLibrary.UnlockKey('jw68e4dk8u79p79oo4dy3oo3y');
  // V#op5q~i#1km@Z6FGT98Myw#0
  //assignfile(t,UST8toSys('trial'));
  if (fileexists(UTF8toSys('sv_cheats.txt'))) then
    begin
      RazrabMode.visible:=true;
      SvalkaBox.visible:=true;
      assignfile(t,'sv_cheats.txt');
      reset(t);
      readln(t,s);
      Testing.visible:=true;
      if s='sv_cheats 1' then
        Test.visible:=true;
      closefile(t);
    end;
  //Razrabmode.visible:=true;
end;

procedure TForm1.KonverBaseClick(Sender: TObject);
var d:dat;
s,m:string;
i,j,k,l:integer;
begin
  assignfile(t, 'base.txt');
  assignfile(f, 'base.dat');
  if FileExists('base.txt') then
    begin
      reset(t);
      rewrite(f);
      l:=1;
      KonverBase.Caption:='Edit the database file';
    //  with d do          //сброс d
      d:=sbrosD(d);
      readLn(t,d.x);
      seek(f,0);
      write(f,d);
      seek(f,l);
      while not(eof(t)) do
      begin
        readln(t,s);
        //with d do          //сброс d
        d:=sbrosD(d);
       // showmessage(d.tex);
        begin            //запись ключевого слова
        j:=1;
        m:='';
        if s[1]='/' then
          m:=''
        else
          begin
            while s[j]<>'/' do
              begin
                m:=m+s[j];
                j:=j+1;
              end;
          end;
        d.x:=m;
        end;

        begin            //поиск параметров
       // showmessage(s);
        for i:=1 to 9 do
          begin
          if pos(a[i],s)<>0 then
          case i of
            1:
            begin
             // showmessage( s[pos(a[i],s)+length(a[i])+1]);
              d.probel:=strtoint( (s[pos(a[i],s)+length(a[i])+1]) );
            end;
            2:
            begin  
             // showmessage( s[pos(a[i],s)+length(a[i])+1]);
              d.stolb:=strtoint((s[pos(a[i],s)+length(a[i])+1]))
            end;
            3:
            begin
           //   showmessage( s[pos(a[i],s)+length(a[i])+1]);
              d.propusk:=strtoint((s[pos(a[i],s)+length(a[i])+1]))
            end;
            4:
            begin
              for k:=(pos(a[i],s)+length(a[i])+1) to length(s) do
                d.endOfTabl:=d.endOfTabl+s[k];
             // showmessage(d.endOfTabl)
            end;
            5:begin
              d.vlevo:=strtoint((s[pos(a[i],s)+length(a[i])+1]))
            end;
            6: d.time:=true;
            7: d.stroka:=true;
            8: d.limitmin:=true;
            9: d.limitmax:=true;
            end;

          end;
        //showmessage(inttostr(d.probel);

       end;
          m:='';
          j:=j+1;
          while ( (s[j]<>'/') and (j<=length(s)) ) do
          begin
            m:=m+s[j];
            j:=j+1;
           // showmessage(m);
          end;
          d.tex:=m;
          seek(f,l);
          write(f,d);
          l:=l+1;
      end;
    //  showmessage('ЗАКРОЙ ПРОГУ');
      closefile(t);
      erase(t);
      closefile(f);
    end
  else
    begin
      KonverBase.Caption:='Save the database file';
      rewrite(t);
      reset(f);
      l:=1;
      s:='';
      read(f,d);
      writeLn(t,utf8string(d.x));
      seek(f,l);
    //  with d do          //сброс d
      d:=sbrosD(d);
      while not(eof(f)) do
      begin
      read(f,d);
      s:=d.x+'/'+d.tex;
    //  s:=d.tex;
      if d.probel<>0 then
        s:=s+'/        ' + a[1] + '=' + inttostr(d.probel );
      if d.stolb<>0 then
        s:=s+'/        ' + a[2] + '=' + inttostr(d.stolb );
      if d.propusk<>0 then
        s:=s+'/        ' + a[3] + '=' + inttostr(d.propusk);
      if d.vlevo<>0 then
        s:=s+'/        ' + a[5] + '=' + inttostr(d.vlevo);
      if d.time then
        s:=s+'/        ' + a[6];
      if d.stroka then
        s:=s+'/        ' + a[7];
      if d.limitmin then
        s:=s+'/        ' + a[8];
      if d.limitmax then
        s:=s+'/        ' + a[9];
      if d.endOfTabl<>'' then
        s:=s+'/        ' + a[4] + '=' + d.endOfTabl;

      //showmessage(s);
      writeLn(t,utf8string(s));
      l:=l+1;
      seek(f,l);
      end;
      closefile(t);
     // erase(t);
      closefile(f);
    end;
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var d:dat;

begin
  if SelectDirectoryDialog1.Execute then
    begin
      assignfile(f,UTF8toSys('base.dat'));
      reset(f);
      seek(f,0);
      read(f,d);
      d.x:=utf8tosys(SelectDirectoryDialog1.fileName+'\');
      seek(f,0);
      write(f,d);
      closefile(f);
    end;
end;

procedure TForm1.report_typeClick(Sender: TObject);
var d:dat;
begin
 OpenDialog2.filter:='Base file only|*.base';
  if OpenDialog2.Execute then
    begin
      assignfile(f,UTF8toSys('base.dat'));
      reset(f);
      seek(f,0);
      read(f,d);
      savedir:=d.x;
      closefile(f);
      if not(fileutil.CopyFile((OpenDialog2.FileName),('base.dat'),false)) then
                showmessage('Copy error! Error code:' + IntToStr(GetLastError))
      else
        begin
          showmessage('Success!');
          assignfile(f,UTF8toSys('base.dat'));
          reset(f);
          seek(f,0);
          write(f,d);
          closefile(f);
        end;
    end;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin

end;

procedure TForm1.MinTimerTimer(Sender: TObject);
begin
  Minut.caption:=inttostr(strtoint(Minut.caption)+1);
end;

procedure TForm1.RadioButton2Change(Sender: TObject);
begin

end;

procedure TForm1.SekTimerTimer(Sender: TObject);
begin
 Sek.caption:=inttostr(strtoint(Sek.caption)+1);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var LogDrives: set of 0..25;
buf: set of 0..25;
mt:set  of 0..25;
flag,go:boolean;
searchResult : TSearchRec;
i,k,l,h,y,j,g,kolvo,setik,stran,startoftabl,r,testint,dlina_m, tabl_i, tabl_j, stolb_count,jorj: longint;
q,s,m,z,z1,z2,z3,teststring,endtabl:string;
d:dat;
tabl:boolean;
mass: array[1..10,1..200] of string;
buf1:string;
etalon_position,etalon_interval,test_position,test_interval,test_nomer, warning_nomer:integer;
test_id,test_stroka:string;
flag_of_LimitMin,flag_of_LimitMax:boolean;
test_array:array[1..10000] of testrecord;   //массив с инфой о всех ошибках
mass_warnings:array[1..10000] of integer;   //массив с инфой о номерах проблемных файлов
testfile:textfile;
test_pred:string;
int_pred,int_nast:integer;
int_nomer_poroga_v_texte,int_nomer_poroga:integer;
limitmin,limitmax:string;
limit_extra_min,limit_extra_max:real;
buf2:string;
int_buf:integer;
begin
  Button2.caption:='Stop conversion';
  mt:=[];
  integer(LogDrives) := GetLogicalDrives;
  buf := LogDrives - SysDisks;
  for j:=0 to 5 do
    if (not(NewDisks[j] in LogDrives) and (NewDisks[j]<>-1)) then
      begin
        NewDisks[j]:=-1;
      //  showmessage('Флешку украли');
      end;
  go:=false;
  if buf <> mt then
    begin
      i:=0;
      while not(i in buf) do
        begin
          i:=i+1;
        end;
      j:=0;
      flag:=false;
      for j:=0 to 5 do
        if (NewDisks[j] in buf) then
          flag:=true;
      if not(flag) then
        begin
          j:=0;
          while (NewDisks[j]<>-1) do
            j:=j+1;
          NewDisks[j]:=i;
          go:=true;
        //  showmessage(chr(i+65)+':\*.pdf');
          if FindFirst(chr(i+65)+':\*.pdf', faAnyFile, searchResult) = 0 then
              begin

                {SekTimer.enabled:=true;
             MinTimer.enabled:=true;
             Sek.caption:='0';
             Minut.caption:='0';
             Sek.visible:=true;
             Minut.visible:=true;   }
             int_nomer_poroga_v_texte:=0;
             int_nomer_poroga:=0;
             ProgressBar1.visible:=true;
             Limit_extra_Min:=10000;
             limit_extra_max:=-10000;
             assignfile(f, 'base.dat');
             reset(f);
             read(f,d);
             savedir:=d.x;
            // with d do          //сброс d
             d:=sbrosD(d);
                q:=chr(i+65)+':\'+searchresult.name;
                if SvalkaBox.checked then
              begin
             assignfile(t, savedir+'svalka.txt');
             if FileExists(savedir+'svalka.txt') then
               reset(t)
             else
               rewrite(t);
             while not(eof(t)) do
               readln(t);
             end;
             tabl:=false;
             for k:=1 to (filesize(f)-1) do
               begin
                 seek(f,k);
                 read(f,d);
                 b[k]:=d;
               end;
               //q:=SelectDirectoryDialog1.FileName+'\'+searchResult.name;
               PDFLibrary.LoadFromFile(widestring(q), '');
               //showmessage(q);
               j:=1;
               while q[j]<>'.' do
                 begin
                   if q[j]='\' then
                     s:=''
                   else
                     s:=s+q[j];
                   j:=j+1;
                 end;
               //showmessage(savedir+s);
               if not(SvalkaBox.checked) then
               begin
                 assignfile(t,savedir+s+'.txt');
                 rewrite(t);
               end;
             //  showmessage(inttostr(PDFLibrary.pageCount));
               //showmessage(q);
               for j:=1 to k do
                 b[j].checked:=false;
               if not(SvalkaBox.checked) then
                 stran:=PDFLibrary.pageCount
               else
                 stran:=1;
               tabl:=false;
               for i:=1 to  stran do
                 begin
                 PDFLibrary.SelectPage(i);
                 m:=PDFLibrary.getpagetext(7);
                 //showmessage(m);
               // if not(flag_of_limitmax and flag_of_limitmin) then
                if not(tabl) then
                 for j:=1 to k do
                   begin
                     //if d.x:'' then
                     if not(b[j].checked) then
                       begin
                 y:=pos(b[j].x, m);
                   if (y<>0) then
                       begin
                         d:=sbrosD(d);
                         d:=b[j];
                         s:='';
                         b[j].checked:=true;
                         l:=y+length(d.x);
                     if d.limitmin then
                     begin
                       flag_of_limitmin:=true;
                       limitmin:=d.x;
                     end;
                     if d.limitmax then
                     begin
                       flag_of_limitmax:=true;
                       limitmax:=d.x;
                     end;

                     if d.propusk<>0 then
                       for h:=1 to d.propusk do
                           begin
                           while (m[l])<>utf8string(#13) do
                           begin
                             l:=l+1;
                             //showmessage(utf8string('"' +m[l-5]+ m[l-4]+m[l-3]+m[l-2]+m[l-1]+ m[l]+m[l+1]+m[l+2]+m[l+3]+m[l+4]+'"'));
                            // showmessage(inttostr(word(m[l])));
                             end;
                           l:=l+2;
                           while m[l]=' ' do
                             l:=l+1;
                           end;
                     if d.vlevo<>0 then
                       begin
                         for h:=1 to d.vlevo do
                           begin
                             while m[l]=' ' do
                               l:=l-1;
                             while m[l]<>' ' do
                               l:=l-1;
                             while m[l]=' ' do
                               l:=l-1;
                             while m[l]<>' ' do
                               l:=l-1;
                             l:=l+1;
                           end;
                       end;
                     if d.stolb<>0 then
                       for h:=1 to d.stolb do
                         begin
                           while m[l]<>' ' do
                             l:=l+1;
                           while m[l]=' ' do
                             l:=l+1;
                         end;
                     if d.endOfTabl<>'' then
                       begin
                       tabl:=true;
                       startoftabl:=y;
                       endtabl:=d.endOfTabl;
                       b[j].checked:=false
                      { teststring:='';
                       for r:=-10 to 1000 do
                         teststring:=teststring+m[l+r];
                       showmessage(teststring);
                       teststring:='';
                       //showmessage(m);
                      // showmessage(d.x);
                       z:='';     }
                       end
                     else
                     if not (flag_of_limitmin or flag_of_limitmax) then

                     begin                //запись с учетом probel
                     if m[l+1]<>'-' then
                     repeat
                       if (m[l]=' ') then
                         begin
                         d.probel:=d.probel-1;
                         s:=s+m[l];
                         l:=l+1;
                         end;
                       while ((m[l]<>' ' ) and (m[l]<>#13)) do
                         begin
                       s:=s+m[l];
                     // if m[l]=#13 then showmessage('"' + m[l] + '"');
                       l:=l+1;

                         end;

                     until (d.probel=0)
                     else
                       s:=m[l];
                     end;
                     if d.time then
                       if m[l+1]<>'-' then
                       s:=data(s)
                       else
                       s:='-';
                     //  b[j]
                //    showmessage('"'+d.tex+'"'+'+'+'"'+s+'"');
                      //showmessage(d.tex+s);
                      if not(tabl or (flag_of_limitmin or flag_of_limitmax)) then
                        begin

                        if d.stroka then
                        begin
                          write(t,d.tex+s+', ');
                          test_position:=test_position+1;
                        end
                        else
                        begin
                          writeln(t,d.tex+s);
                          //test_position:=test_position+1;
                          if testing.checked then
                          begin
                            if pos('Logging Interval',d.tex+s)<>0 then
                              etalon_interval:=strtoint(s);
                            test_position:=test_position+1;
                          end;
                        //  showmessage(d.tex+s);
                        end
                        end;
                      if (flag_of_limitmin and flag_of_limitmax) then
                      begin
                        flag_of_limitmin:=false;
                        test_position:=test_position+2;
                        flag_of_limitmax:=false;
                        int_nomer_poroga_v_texte:=find_next_porog(m,limitmin,limitmax);
                        int_nomer_poroga:=int_nomer_poroga+1;
                        writeln(t,' Alarms');

                        while int_nomer_poroga_v_texte<>0 do
                          begin
                            writeln(t,'  '+inttostr(int_nomer_poroga)+': ');
                            if Check_porog_time(m,int_nomer_poroga_v_texte)='-' then
                              write(t,'Single event: ')
                            else
                              write(t,'Accumulated: ');
                            buf1:=find_temp(m,int_nomer_poroga_v_texte);
                            buf1[pos('.',buf1)]:=',';
                            //showmessage(buf1);
                            buf2:='';
                            for int_buf:=0 to 20 do
                              buf2:=buf2+m[int_nomer_poroga_v_texte+int_buf];
                            // showmessage(m[int_nomer_poroga_v_texte]+m[int_nomer_poroga_v_texte+1]+m[int_nomer_poroga_v_texte+2]+m[int_nomer_poroga_v_texte+3]+m[int_nomer_poroga_v_texte+4]+m[int_nomer_poroga_v_texte+5]+m[int_nomer_poroga_v_texte+6]+m[int_nomer_poroga_v_texte+7]+m[int_nomer_poroga_v_texte+8]+m[int_nomer_poroga_v_texte+9]+m[int_nomer_poroga_v_texte+10]);
                            if pos(limitmin,buf2)<>0 then
                            begin
                              write(t,'bellow T=');
                              if strtofloat(buf1)<limit_extra_min then
                                limit_extra_min:=strtofloat(buf1);
                            end;
                            if pos(limitmax,buf2)<>0 then
                              begin
                              write(t,'above T=');
                              if strtofloat(buf1)>limit_extra_max then
                                limit_extra_max:=strtofloat(buf1);
                              end;
                            buf1:='';
                            buf2:='';
                            int_buf:=0;
                            write(t,find_temp(m,int_nomer_poroga_v_texte));
                            if Check_porog_time(m,int_nomer_poroga_v_texte)<>'-' then
                              writeln(t,' for ' + Check_porog_time(m,int_nomer_poroga_v_texte))
                            else
                              writeln(t,' ');
                            write(t,'Status: ');
                            writeln(t,text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,2),0));

                            if data(text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,3),1))<>'-' then
                            begin
                            write(t, 'Date and time of alarm: ');
                            writeLn(t, data(text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,3),1)));
                            write(t,'Time elapsed from start to alarm: ');
                            writeln(t,text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,5),0));
                            write(t,'Total Number of exits beyond the threshold: ');
                            writeln(t,text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,6),0));
                            write(t,'Maximum time of exceeding the threshold value: ');
                            writeln(t,text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,7),0));
                            write(t,'Total time beyond thee threshold value: ');
                            writeln(t,text_and_probels(m,propusk_stolb(m,int_nomer_poroga_v_texte,8),0));
                            end;
                            writeLn(t,' ');
                            m[int_nomer_poroga_v_texte]:='1';
                            int_nomer_poroga:=int_nomer_poroga+1;

                            int_nomer_poroga_v_texte:=find_next_porog(m,limitmin,limitmax);
                           // showmessage(inttostr(int_nomer_poroga_v_texte));
                          end;

                        //writeLn(t,'something about limits');
                      end
                     // showmessage(d.tex+s);
                     //showmessage(inttostr(word(m[l])));
                     end

                   else
                     begin
                       if (b[j].x='*') then
                         begin
                        //   showmessage(d.x);
                           b[j].checked:=true;
                           writeln(t,b[j].tex);
                           test_position:=test_position+1;
                         end;
                 end;
                     end;
                     end;

                if tabl then
                  begin
               //   showmessage('Start tabl');
                  l:=startoftabl;
                  for h:=1 to 2 do
                    begin
                      while (m[l])<>utf8string(#13) do
                        begin
                          l:=l+1;
                             //showmessage(utf8string('"' +m[l-5]+ m[l-4]+m[l-3]+m[l-2]+m[l-1]+ m[l]+m[l+1]+m[l+2]+m[l+3]+m[l+4]+'"'));
                            // showmessage(inttostr(word(m[l])));
                        end;
                        l:=l+2;

                        while m[l]=' ' do
                          l:=l+1;
                        end;
                      s:='';
                   //   showmessage('');
                     // testint:=0;
                     for tabl_i:=1 to 6 do
                       for tabl_j:=1 to 500 do
                         mass[tabl_i,tabl_j]:='';
                     tabl_i:=0;
                     tabl_j:=1;
                     //if
                     begin
                     stolb_count:=1;
                     while pos(m[l+h],solve)<>0 do
                           h:=h+1;
                     while m[l+h]<>#13 do
                       begin
                         while pos(m[l+h],solve)=0 do
                           h:=h+1;
                         while pos(m[l+h],solve)<>0 do
                           h:=h+1;
                         stolb_count:=stolb_count+1;
                       end;
                     stolb_count:=stolb_count div 3;
                     h:=0;
                     end;
                     z1:='';
                     z2:='';
                     z3:='';
                     z:='';
                     s:='';
                  //   showmessage(inttostr(stolb_count));
                      while (pos(d.endoftabl,z)=0) do
                        begin
                          if length(z)>0 then
                          begin
                          z1:=data(z1);
                          if length(z3)>0 then
                          begin
                           buf1:=z3;
                          buf1[pos('.',buf1)]:=',';
                          if ((Limit_extra_Min=10000) and (Limit_extra_Max=-10000)) then
                            z3:=z3+' x'
                          else
                            begin
                          if ((strtofloat(buf1)>=Limit_extra_Min) and (strtofloat(buf1)<=Limit_extra_Max)) then
                            z3:=z3+' Ok'
                          else
                            z3:=z3+' x';
                          end;
                          end;
                          z:=z1+' ' +z3;
                          { teststring:='';
                          for r:=0 to 1000 do
                         teststring:=teststring+m[l+r];
                       showmessage(teststring);
                       teststring:=''; }
                          s:=s+z;
                          end;
                         // showmessage(z);

                          {testint:=testint+1;
                          if testint>(700*2.28) then
                          begin
                            teststring:='';
                            for r:=0 to 100 do
                            teststring:=teststring+m[l+r];
                               showmessage(teststring);
                            teststring:='';
                          end;}
                        //  showmessage(z);
                          if length(z)>0 then
                          begin
                          if (pos(z[7],solve)<>0)then
                            begin
                              tabl_i:=tabl_i+1;
                              if tabl_i>stolb_count then
                                begin
                                  tabl_i:=1;
                                  tabl_j:=tabl_j+1;
                                end;
                              mass[tabl_i,tabl_j]:=z;
                             // showmessage(mass[tabl_i,tabl_j]+' ['+inttostr(tabl_i)+','+inttostr(tabl_j)+']');
                           end;
                          end;
                         // else
                         teststring:='';
                         for jorj:=-10 to 0 do
                           teststring:=teststring+m[l+jorj];
                         //showmessage(teststring);
                          if pos(#10,teststring)<>0 then
                          begin
                            stolb_count:=1;
                            while pos(m[l+h],solve)<>0 do
                             h:=h+1;
                            while m[l+h]<>#13 do
                              begin
                              while pos(m[l+h],solve)=0 do
                                h:=h+1;
                              while pos(m[l+h],solve)<>0 do
                                h:=h+1;
                              stolb_count:=stolb_count+1;
                              end;
                          stolb_count:=stolb_count div 3;
                       //  if stolb_count>6 then showmessage(inttostr(stolb_count));
                          h:=0;
                          end;
                          z:='';
                          z1:='';
                          z2:='';
                          z3:='';
                          dlina_m:=length(m);
                         // if (l<length(m)) then
                          while ((pos(m[l],solve+d.endoftabl)<>0) ) do
                            begin
                              z1:=z1+m[l];
                              l:=l+1;
                            end;
                          h:=0;
                         // if ((l+h)<length(m)) then
                          while ((pos(m[l+h],solve+d.endoftabl)=0) and(h<10)) do
                            begin
                              h:=h+1;
                            end;
                          if (h<5) then
                          begin
                            l:=l+h;
                          //  if length(m)>0 then
                        //  if (l<length(m)) then
                            while ((pos(m[l],solve+d.endoftabl)<>0) ) do
                              begin
                            z2:=z2+m[l];
                            l:=l+1;
                              end;
                          end;
                          h:=0;
                        //  if ((l+h)<length(m)) then
                          while ((pos(m[l+h],solve+d.endoftabl)=0) and (h<5)) do
                            begin
                              h:=h+1;
                            end;
                          if (h<5) then
                          begin
                            l:=l+h;
                          //  if (l<length(m)) then
                             while ((pos(m[l],solve+d.endoftabl)<>0)) do
                              begin
                            z3:=z3+m[l];
                            l:=l+1;
                              end;
                          end;
                          z1:=z1+' '+z2;
                          z:=z1+' '+z3;

                         // showmessage(z1);
                          //showmessage(z2);
                          //showmessage(z3);
                         // showmessage(z);
                        //  if (l<length(m)) then
                          while ( (pos(m[l],solve+d.endoftabl)=0) and (l<length(m)) ) do
                            l:=l+1;
                          //showmessage(s);
                        end;
                      z:='';
                      tabl:=false;
                      tabl_i:=1;
                      h:=1;
                      while mass[tabl_i,h]<>'' do
                       begin
                         h:=1;
                        // if h<7 then
                         while (h<=tabl_j) do
                          begin

                           if length(mass[tabl_i,h])>21 then
                           begin
                             writeln(t,mass[tabl_i,h]);
                           //etalon_interval
                           if ((testing.checked) and (test_pred<>''))  then
                             begin
                       //      showmessage(mass[tabl_i,h]);
                       //      showmessage(mass[tabl_i,h][15]+mass[tabl_i,h][16]);
                             int_nast:=strtoint(mass[tabl_i,h][15]+mass[tabl_i,h][16]);
                             int_pred:=strtoint(test_pred[15]+test_pred[16]);
                               if not((int_nast-int_pred=etalon_interval) or (int_nast-int_pred=etalon_interval-60)) then
                                 begin
                               //  showmessage(inttostr(int_nast-int_pred));
                               //  showmessage(inttostr(int_nast-int_pred)+' '+test_array[test_nomer].id+' ' +mass[tabl_i,h] +' - ' + test_pred);
                                   if not(test_array[test_nomer].flag) then
                                     warning_nomer:=warning_nomer+1;
                                   test_array[test_nomer].flag:=true;
                                   test_array[test_nomer].interval:=true;
                                   mass_warnings[warning_nomer]:=test_nomer;
                                   test_array[test_nomer].punkt_v_tabl:=mass[tabl_i,h];
                                 end;

                             end;
                           test_pred:=mass[tabl_i,h];
                           end;
                           //if (strtoint(mass[tabl_i,h][15]+mass[tabl_i,h][16])
                           h:=h+1;
                        //   showmessage(mass[tabl_i,h]);
                           end;
                         tabl_i:=tabl_i+1;
                         h:=1;
                       end;
                     { for tabl_i:=1 to 6 do
                        for h:=1 to tabl_j do
                         // if pos
                          writeln(t, mass[tabl_i,h]);}

                  end;

               if testing.checked then
                 begin
                   test_array[test_nomer].pos:=test_position;
                 end;

               if not(SvalkaBox.checked) then

               end;

               setik:=setik+1;
               //ProgressBar1.position:=round(100*(setik/kolvo));
               if not(SvalkaBox.checked) then
               closefile(t);
               closefile(f);
                if SvalkaBox.checked then
                closefile(t);
                ProgressBar1.visible:=false;
             //   ProgressBar1.position:=0;
           //  showmessage('"'+pchar(q)+'"');
            // showmessage('"'+pchar(savedir+searchresult.name)+'"');
             if copy then
             begin
             if not(fileutil.CopyFile((q),(savedir+searchresult.name),false)) then
                showmessage('Copy error! Error code:' + IntToStr(GetLastError))
             else
                 sndPlaySound('success.wav',snd_Async);
             end
             else
               sndPlaySound('success.wav',snd_Async);
    end;
           end;
        end;
    end;

//PDFLibrary.Free; ;

end.

