clear

n_mem=10;
n_cot=2;
n_game=10;

n_ng=n_mem-4*n_cot;

[game_mem, ngame_mem, game_memsum]=game_member(n_mem,n_cot,n_game);

%test
%load gamemmem ;

team0=nchoosek(1:n_mem,4);
n_team0=length(team0);
team0=[(1:n_team0)' team0];

games1=zeros(n_mem,n_mem);
games2=zeros(n_mem,n_mem);
games1temp=games1;
games2temp=games2;

team0(:,6)=sum(2.^team0(:,2:5),2); %5列目　メンバー指数
team0=[team0 zeros(n_team0,3)];

%Game 1
%game(1).member=reshape(game_mem(:,1),4,n_cot)';

for ga=1:n_game
  %ゲーム参加者
  if n_ng>0
    l=find(bitand(team0(:,6),sum(2.^ngame_mem(:,ga)))==0);
    team1=team0(l,:);
  else
    team1=team0;
  end


  mem_tmp0=[];
  flag=0;
  sel=1;

%  while flag==0
  for co=1:n_cot
    %組み合わせ回数ソート
    [tmp,ll]=sort(team1(:,7));
    team2=team1(ll,:);
    n_team2=length(team2(:,1));

    [tmp,ll2]=sort(team2(:,9));
    team2b=team2(ll2,:);

    %11/30
    [tmp,ll2]=sort(team2(:,8));
    team2b=team2(ll2,:);


    if co>1
      mem_tmp0=[mem_tmp0 mem_tmp];
      l=find(bitand(team2b(:,6),sum(2.^mem_tmp0))==0);
      team3=team2b(l,:);
    else
      team3=team2b;
    endif

    [tmp,ll]=sort(team3(:,9));
    team3=team3(ll,:);


    min9=min(team3(:,9));

%    if co==1
%    mem_tmp=team3(sel,2:5);
%  else
    mem_tmp=team3(1,2:5);
%    end


    mem_tmp2=[mem_tmp(1) mem_tmp(2) mem_tmp(3) mem_tmp(4);
              mem_tmp(1) mem_tmp(3) mem_tmp(2) mem_tmp(4);
          mem_tmp(1) mem_tmp(4) mem_tmp(2) mem_tmp(3)];
    for j=1:3
      sel_pare(j)=games2(mem_tmp2(j,1),mem_tmp2(j,2))...
      +games2(mem_tmp2(j,3),mem_tmp2(j,4));
    endfor
    [tmp,l]=sort(sel_pare);
    member_sel=mem_tmp2(l(1),:);
    game(ga).member(co,:)=member_sel;

    games1temp(mem_tmp,mem_tmp)=...
    games1(mem_tmp,mem_tmp)+1;%４人内の数
    %games1=games1-diag(diag(games1));

    games2temp(game(ga).member(co,1:2),game(ga).member(co,1:2))=...
    games2(game(ga).member(co,1:2),game(ga).member(co,1:2))+1;%ペア済数
    games2temp(game(ga).member(co,3:4),game(ga).member(co,3:4))=...
    games2(game(ga).member(co,3:4),game(ga).member(co,3:4))+1;
    %games2=games2-diag(diag(games2));

      games1temp=games1temp-diag(diag(games1temp));
  games2temp=games2temp-diag(diag(games2temp));

    games1j=find(games1temp);
%    if max(games1temp(games1j))-min(games1temp(games1j))<2
%      flag=1;
      games1=games1temp;
      games2=games2temp;
%    else
%     sel=sel+1;
%    endif


end %co

%end %while

  games1=games1-diag(diag(games1));
  games2=games2-diag(diag(games2));

    for j=1:n_team0
    team0(j,7)=sum(sum(games1(team0(j,2:5),team0(j,2:5))));
%    +max(max(games1(team0(j,2:5),team0(j,2:5))));
    team0(j,8)=sum(sum(games2(team0(j,2:5),team0(j,2:5))));
    team0(j,9)=max(max(games1(team0(j,2:5),team0(j,2:5))));
    end





end

if 0
clear kumi
kumi(1).member=zeros(1,4);
for j=2:12
kumi(j).member=[kumi(j-1).member;zeros(1,4);game(j-1).member];
end
csvwrite('kumi.csv',kumi(12).member)
end







