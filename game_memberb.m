function [game_mem, ngame_mem, game_memsum] = game_memberb(n_mem,n_cot,n_game)

% n_mem = 参加人数
% n_cot = コート数
% n_game = ゲーム数
%
% game_mem    : 各ゲームの参加者
% ngame_mem   : 各ゲームの休みの人
% game_memsum : 各ゲームの参加者ビットマスク

if n_mem < 4*n_cot
    error('参加人数がコート数に対して不足しています。');
end

n_ng = n_mem - 4*n_cot;

game_mem = zeros(4*n_cot,n_game);
ngame_mem = zeros(n_ng,n_game);
game_memsum = zeros(1,n_game);

% 各人が休んだ回数
restCount = zeros(n_mem,1);

% 2人が同時に休んだ回数
restPairCount = zeros(n_mem,n_mem);

for j = 1:n_game

    %==================================================
    % Game 1 は、番号の大きい人を休みにする
    %
    % 例：11人・2面
    % 参加：1～8
    % 休み：9 10 11
    %==================================================
    if j == 1

        rest = (n_mem-n_ng+1:n_mem)';

    else

        %================================================
        % 2ゲーム目以降の休みメンバーを決定
        %================================================
        rest = [];
        available = (1:n_mem)';

        for k = 1:n_ng

            %--------------------------------------------
            % 今回すでに休みに選ばれた人との
            % 同時休み回数
            %--------------------------------------------
            if isempty(rest)

                pairScore = zeros(size(available));

            else

                pairScore = sum(restPairCount(available,rest),2);

            end


            %--------------------------------------------
            % まず、これまでの休み回数が少ない人を優先
            %--------------------------------------------
            rc = restCount(available);

            minRest = min(rc);

            candidateIndex = find(rc == minRest);


            %--------------------------------------------
            % 次に、同じ人と一緒に休んだ回数が少ない人を優先
            %--------------------------------------------
            ps = pairScore(candidateIndex);

            minPair = min(ps);

            candidateIndex = candidateIndex(ps == minPair);

            candidate = available(candidateIndex);


            %--------------------------------------------
            % 同点の場合はゲームごとに選択位置をずらす
            %--------------------------------------------
            priority = mod(candidate - 1 - mod(j-1,n_mem),n_mem);

            [~,idx] = min(priority);

            pick = candidate(idx);


            %--------------------------------------------
            % 今回の休みに追加
            %--------------------------------------------
            rest = [rest; pick];


            %--------------------------------------------
            % 選択済みの人を候補から除外
            %--------------------------------------------
            available(available == pick) = [];

        end

    end


    %==================================================
    % 休みメンバーを保存
    %==================================================
    ngame_mem(:,j) = rest;


    %==================================================
    % 休んだ回数を更新
    %==================================================
    restCount(rest) = restCount(rest) + 1;


    %==================================================
    % 同時に休んだ2人の回数を更新
    %==================================================
    for a = 1:n_ng

        for b = a+1:n_ng

            p1 = rest(a);
            p2 = rest(b);

            restPairCount(p1,p2) = ...
                restPairCount(p1,p2) + 1;

            restPairCount(p2,p1) = ...
                restPairCount(p2,p1) + 1;

        end

    end


    %==================================================
    % 休みではない人 = 今回のゲーム参加者
    %==================================================
    isPlaying = true(n_mem,1);

    isPlaying(rest) = false;

    players = find(isPlaying);

    game_mem(:,j) = players;


    %==================================================
    % ビットマスク
    %==================================================
    game_memsum(j) = sum(2.^players);

end

end
