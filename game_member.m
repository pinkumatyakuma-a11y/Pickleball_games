function [game_mem, ngame_mem, game_memsum]=game_member(n_mem,n_cot,n_game);

%n_mem=12;
%n_cot=3;
%n_game=10;
n_ng=n_mem-4*n_cot;

if n_ng>0
  temp1=(4*n_cot+1:n_mem)';
  for j=1:n_game+1
    temp1=[temp1;(1:n_mem)'];
  end
  ngame_mem=reshape(temp1(1:n_ng*n_game),n_ng,n_game);
  for j=1:n_game
    temp3=(1:n_mem)';
    l=find(~bitand(2.^(1:n_mem),sum(2.^ngame_mem(1:n_ng,j))));
    game_mem(:,j)=temp3(l);
    game_memsum(j)=sum(2.^(temp3(l)));
  end
else
  game_mem=ones(4*n_cot,n_game).*(1:n_mem)';
  ngame_mem=[];
  game_memsum=ones(1,n_game)*sum(2.^(1:n_mem));



end







