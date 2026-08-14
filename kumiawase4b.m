clear

n_mem=11;
n_cot=2;
n_game=10;

n_ng=n_mem-4*n_cot;

[game_mem,ngame_mem,game_memsum]=game_memberb(n_mem,n_cot,n_game);

team0=nchoosek(1:n_mem,4);
n_team0=length(team0);
team0=[(1:n_team0)' team0];

games1=zeros(n_mem,n_mem);
games2=zeros(n_mem,n_mem);

games1temp=games1;
games2temp=games2;

% 4人組のメンバー指数
team0(:,6)=sum(2.^team0(:,2:5),2);

% 7列目：4人組内の組み合わせ回数
% 8列目：4人組内のペア回数
% 9列目：4人組内の最大組み合わせ回数
team0=[team0 zeros(n_team0,3)];


for ga=1:n_game

  %-----------------------------------------
  % ゲーム参加者だけに候補を限定
  %-----------------------------------------
  if n_ng>0
    l=find(bitand(team0(:,6),sum(2.^ngame_mem(:,ga)))==0);
    team1=team0(l,:);
  else
    team1=team0;
  endif


  mem_tmp0=[];


  %=========================================
  % コートごとの組み合わせ
  %=========================================
  for co=1:n_cot

    %---------------------------------------
    % これまでの組み合わせ回数を更新
    %---------------------------------------
    for j=1:length(team1(:,1))

      mm=team1(j,2:5);

      team1(j,7)=sum(sum(games1(mm,mm)));

      team1(j,8)=sum(sum(games2(mm,mm)));

      team1(j,9)=max(max(games1(mm,mm)));

    endfor


    %---------------------------------------
    % 既に同じゲームで使用した人を除外
    %---------------------------------------
    if co>1

      mem_tmp0=[mem_tmp0 mem_tmp];

      l=find(bitand(team1(:,6),sum(2.^mem_tmp0))==0);

      team3=team1(l,:);

    else

      team3=team1;

    endif


    %---------------------------------------
    % 候補を評価
    %
    % 7列：4人の組み合わせ総回数
    % 8列：ペアの総回数
    % 9列：最大組み合わせ回数
    %
    % 小さいものを優先
    %---------------------------------------

    score=zeros(length(team3(:,1)),1);

    for j=1:length(team3(:,1))

      mm=team3(j,2:5);

      % 4人組内の組み合わせ回数
      s1=sum(sum(games1(mm,mm)));

      % 4人組内のペア回数
      s2=sum(sum(games2(mm,mm)));

      % 最大組み合わせ回数
      s3=max(max(games1(mm,mm)));

      % 評価値
      %
      % 組み合わせの最大値を特に重視
      % 次にペア回数
      % 最後に組み合わせ総数
      %
      score(j)=100*s3 + 10*s2 + s1;

    endfor


    %---------------------------------------
    % 最も評価の低い4人組を選択
    %---------------------------------------
    [tmp,ll]=sort(score);

    mem_tmp=team3(ll(1),2:5);


    %---------------------------------------
    % 4人の中のペア配置も調整
    %
    % 2対2の組み合わせを3通り比較
    %---------------------------------------
    mem_tmp2=[ ...
      mem_tmp(1) mem_tmp(2) mem_tmp(3) mem_tmp(4);
      mem_tmp(1) mem_tmp(3) mem_tmp(2) mem_tmp(4);
      mem_tmp(1) mem_tmp(4) mem_tmp(2) mem_tmp(3)];


    sel_pare=zeros(1,3);

    for j=1:3

      sel_pare(j)= ...
        games2(mem_tmp2(j,1),mem_tmp2(j,2)) + ...
        games2(mem_tmp2(j,3),mem_tmp2(j,4));

    endfor


    [tmp,l]=sort(sel_pare);

    member_sel=mem_tmp2(l(1),:);

    game(ga).member(co,:)=member_sel;


    %---------------------------------------
    % games1 更新
    % 4人が同じゲームをした回数
    %---------------------------------------
    games1temp(member_sel,member_sel)= ...
      games1(member_sel,member_sel)+1;

    games1temp=games1temp-diag(diag(games1temp));


    %---------------------------------------
    % games2 更新
    % ペアとして組んだ回数
    %---------------------------------------
    p1=member_sel(1:2);
    p2=member_sel(3:4);

    games2temp(p1,p1)= ...
      games2(p1,p1)+1;

    games2temp(p2,p2)= ...
      games2(p2,p2)+1;

    games2temp=games2temp-diag(diag(games2temp));


    %---------------------------------------
    % 更新
    %---------------------------------------
    games1=games1temp;
    games2=games2temp;


    % 次のコートで同じ人を使わない
    mem_tmp=member_sel;

  endfor


  %=========================================
  % 次ゲーム用の評価値を更新
  %=========================================
  for j=1:n_team0

    mm=team0(j,2:5);

    team0(j,7)=sum(sum(games1(mm,mm)));

    team0(j,8)=sum(sum(games2(mm,mm)));

    team0(j,9)=max(max(games1(mm,mm)));

  endfor


endfor


%=============================================
% 対角成分を0にする
%=============================================
games1=games1-diag(diag(games1));
games2=games2-diag(diag(games2));


%=============================================
% 結果表示
%=============================================
game.member

games1

games2
