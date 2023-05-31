%author:Liyichen
%date:2023/5/9

clear;close all;clc;
color_board = [238 197 145]; %棋盘背景颜色
color_line = [105 105 105]; %棋盘背景颜色
board_size = 15; %棋盘大小
dpixel = 33; %相邻棋盘线间的像素间隔
width_edge = 18; %棋盘边缘的像素宽度
radius_dot = 5; %棋盘9个小圆点大小

game = init_game(board_size);

radius_chess = 13;
color_black_chess = [54 54 54];
color_white_chess = [255 240 245];
d_input = 10;
turn_back = false;

depth = 4;
table = init_weight_table();


while true
    chessboard = chessboard_gui(color_board,color_line,board_size,dpixel,width_edge,radius_dot);
    imshow(chessboard);
    set(gcf,'position',[625,45,625,625]);
    set(gca,'position',[0,0,1,1]);
    hold on;
    game = reset(game,board_size);
    while true
        if game.current_player == 1
            [x,y] = get_action_human(game,width_edge,dpixel,board_size,d_input);
        else
            [x,y] = get_action_minimax(game,depth,board_size,table);
    %         legal_actions = get_legal_actions(game,board_size);
    %         x = legal_actions(1,1);
    %         y = legal_actions(1,2);
            % [x,y] = get_action_human(game,width_edge,dpixel,board_size,d_input);
        end
        disp([x y]);
        chessboard = step_gui(chessboard,x,y,width_edge,dpixel,game.current_player,turn_back,radius_chess,color_black_chess,color_white_chess,color_board);
        imshow(chessboard);
        game = step(game,board_size,x,y);
        disp(game.board);
        if game.done
            disp('done');
            done_gui(game.winner);
            break;
        end
    end
end


%棋盘gui函数
function chessboard = chessboard_gui(color_board,color_line,board_size,dpixel,width_edge,radius_dot)
    numsum = 1+dpixel*(board_size-1)+width_edge*2;
    line = width_edge+1:dpixel:numsum-width_edge;
    chessboard = uint8(ones(numsum,numsum,3));
    chessboard(:,:,1) = chessboard(:,:,1)*color_board(1);
    chessboard(:,:,2) = chessboard(:,:,2)*color_board(2);
    chessboard(:,:,3) = chessboard(:,:,3)*color_board(3);
    %画棋盘线
    for i = line
        chessboard(i,width_edge+1:numsum-width_edge,:) = ones(numsum-2*width_edge,1)*color_line;
    end
    for j = line
        chessboard(width_edge+1:numsum-width_edge,j,:) = ones(numsum-2*width_edge,1)*color_line;
    end
    %画9个小圆点
    dot = width_edge+1+dpixel*3:dpixel*4:width_edge+1+dpixel*(board_size-4);
    for i = dot
        for j = dot
            for x = i-radius_dot:i+radius_dot
                for y = j-radius_dot:j+radius_dot
                    if (x-i)^2+(y-j)^2 <= radius_dot^2
                        chessboard(x,y,:) = color_line;
                    end
                end
            end
        end
    end
end

%下棋gui
function chessboard = step_gui(chessboard,x,y,width_edge,dpixel,current_player,turn_back,radius_chess,color_black_chess,color_white_chess,color_board)
    x = width_edge+1+dpixel*(x-1);
    y = width_edge+1+dpixel*(y-1);
    for i = x-radius_chess:x+radius_chess
        for j = y-radius_chess:y+radius_chess
            if ~turn_back
                if (i-x)^2+(j-y)^2 <= radius_chess^2
                    if current_player == 1
                        chessboard(i,j,:) = color_black_chess;
                    else
                        chessboard(i,j,:) = color_white_chess;
                    end
                end
            %悔棋
            else
                chessboard(x,y,:) = color_board;
                %恢复小圆点没写
            end
        end
    end
end

function done_gui(winner)
    h=dialog('name','对局结束','position',[500 350 250 100]);
    if winner == 1
        uicontrol('parent',h,'style','text','string','黑棋获胜！','position',[35 35 200 50],'fontsize',20);
    elseif winner == -1
        uicontrol('parent',h,'style','text','string','白棋获胜！','position',[35 35 200 50],'fontsize',20);
    else
        uicontrol('parent',h,'style','text','string','平局','position',[35 35 200 50],'fontsize',20);
    end
    uicontrol('parent',h,'style','pushbutton','position',[150 5 80 30],'fontsize',20,'string','确定','callback','delete(gcbf)');
end

%逻辑五子棋
function game = init_game(board_size)
    game.board = zeros(board_size,board_size);
    game.current_player = 1;
    game.done = false;
    game.winner = 0;
end

function game = reset(game, board_size)
    game.board = zeros(board_size,board_size);
    game.current_player = 1;
    game.done = false;
    game.winner = 0;
end

function game = step(game,board_size,x,y)
    if x>=1 && x<=board_size && y>=1 && y<=board_size && game.board(x,y) == 0
        game.board(x,y) = game.current_player;
        game = is_done(game,board_size,x,y);
        if ~game.done
            game.current_player = -game.current_player;
        end
    else
        disp('invalid step');
    end
end

function legal_actions = get_legal_actions(game, board_size)
    disp(game.board);
    count = 0;
    for i = 1:board_size
        for j = 1:board_size
            if game.board(i,j) == 0
                count = count + 1;
            end
        end
    end
    disp(count);
    legal_actions = zeros(count,2);
    k = 1;
    for i = 1:board_size
        for j = 1:board_size
            if game.board(i,j) == 0
                legal_actions(k,1) = i;
                legal_actions(k,2) = j;
                k = k+1;
            end
        end
    end
end

function game = is_done(game,board_size,x,y)
    if ~any(game.board == 0)
        game.done = true;
    end
    directions = [0 1;1 1;1 0;1 -1];
    cx = x;
    cy = y;
    for i = 1:4
        dx = directions(i,1);
        dy = directions(i,2);
        count = 1;
        x = cx + dx;
        y = cy + dy;
        while x>=1 && x<=board_size && y>=1 && y<=board_size && game.board(x,y)==game.current_player && count<5
            count = count+1;
            x = x+dx;
            y = y+dy;
        end
        x = cx - dx;
        y = cy - dy;
        while x>=1 && x<=board_size && y>=1 && y<=board_size && game.board(x,y)==game.current_player && count<5
            count = count+1;
            x = x-dx;
            y = y-dy;
        end
        if count>=5
            game.done = true;
            game.winner = game.current_player;
            break;
        end
    end
end

function actions = seek_points(board,color,board_size,table)
    count = 0;
    temp_board = int8(zeros(board_size,board_size));
    directions = [0 1;0 -1;1 1;-1 -1;1 0;-1 0;1 -1;-1 1];
    for i=1:board_size
        for j=1:board_size
            if ~board(i,j) == 0
                for k=1:8
                    dx = directions(k,1);
                    dy = directions(k,2);
                    x = i+dx;
                    y = j+dy;
                    l = 0;
                    while l < 3
                        if x<1 || x>board_size || y<1 || y>board_size
                            break;
                        end
                        if board(x,y) == 0 && temp_board(x,y) == 0
                            temp_board(x,y) = 1;
                            count = count+1;
                        end
                        x = x+dx;
                        y = y+dy;
                        l=l+1;
                    end
                end
            end
        end
    end
    if count == 0
        actions = [8 8];
        return
    end
    value_board = zeros(board_size,board_size);
    for i=1:board_size
        for j=1:board_size
            value_board(i,j) = -Inf;
            if temp_board(i,j) == 1
                board(i,j) = color;
                value_board(i,j) = get_value(board,color,board_size,table);
                board(i,j) = 0;
            end
        end
    end
    count = min(count,10);
    actions = zeros(count,2);
    for k=1:count
        max_value = -Inf;
        for i=1:board_size
            for j=1:board_size
                if value_board(i,j) > max_value
                    max_value = value_board(i,j);
                    actions(k,1) = i;
                    actions(k,2) = j;
                end
            end
        end
        value_board(actions(k,1),actions(k,2)) = -Inf;
    end
end
%人下棋
function [x,y] = get_action_human(game,width_edge,dpixel,board_size,d_input)
    flag = false;
    while ~flag
        [y,x] = ginput_pointer(1);
        disp([x y]);
        line = width_edge+1:dpixel:width_edge+1+dpixel*(board_size-1);
        for i = line
            for j = line
                if (x-i)^2+(y-j)^2 <= d_input^2
                    x = (i-width_edge-1)/dpixel+1;
                    y = (j-width_edge-1)/dpixel+1;
                    if game.board(x,y) == 0
                        flag = true;
                        break;
                    end
                end
            end
            if flag
                break;
            end
        end
        disp([x y]);
    end
end

function node = new_node(depth,search_type,alpha,beta,value)
    node.depth = depth;
    node.search_type = search_type;
    node.alpha = alpha;
    node.beta = beta;
    node.value = value;
end

function minimax = new_minimax()
    minimax.max_value = -Inf;
    minimax.best_x = 0;
    minimax.best_y = 0;
end

function a = init_weight_table()
    WIN = 1000000;
    LOSE = -10000000;
    FLEX4 = 50000;
    flex4 = -100000;
    BLOCK4 = 400;
    block4 = -100000;
    FLEX3 = 400;
    flex3 = -8000;
    BLOCK3 = 20;
    block3 = -50;
    FLEX2 = 20;
    flex2 = -50;
    BLOCK2 = 1;
    block2 = -3;
    FLEX1 = 1;
    flex1 = -3;
    c = 1; % node.color
    d = 2; % -node.color
    w = 3; % 0
    u = 4; % 边界
    a = zeros(4,4,4,4,4,4);
    a(c,c,c,c,c,c) = WIN;
    a(c,c,c,c,c,w) = WIN;
    a(w,c,c,c,c,c) = WIN;
    a(c,c,c,c,c,d) = WIN;
    a(d,c,c,c,c,c) = WIN;
    a(c,c,c,c,c,u) = WIN;
    a(u,c,c,c,c,c) = WIN;
    
    a(d,d,d,d,d,d) = LOSE;
    a(d,d,d,d,d,w) = LOSE;
    a(w,d,d,d,d,d) = LOSE;
    a(d,d,d,d,d,c) = LOSE;
    a(c,d,d,d,d,d) = LOSE;
    a(d,d,d,d,d,u) = LOSE;
    a(u,d,d,d,d,d) = LOSE;

    a(w,c,c,c,c,w) = FLEX4;

    a(w,d,d,d,d,w) = flex4;

    a(w,c,c,c,w,w) = FLEX3;
    a(w,w,c,c,c,w) = FLEX3;
    a(w,c,w,c,c,w) = FLEX3;
    a(w,c,c,w,c,w) = FLEX3;

    a(w,d,d,d,w,w) = flex3;
    a(w,w,d,d,d,w) = flex3;
    a(w,d,w,d,d,w) = flex3;
    a(w,d,d,w,d,w) = flex3;

    a(w,c,c,w,w,w) = FLEX2;
    a(w,c,w,c,w,w) = FLEX2;
    a(w,c,w,w,c,w) = FLEX2;
    a(w,w,c,c,w,w) = FLEX2;
    a(w,w,c,w,c,w) = FLEX2;
    a(w,w,w,c,c,w) = FLEX2;

    a(w,d,d,w,w,w) = flex2;
    a(w,d,w,d,w,w) = flex2;
    a(w,d,w,w,d,w) = flex2;
    a(w,w,d,d,w,w) = flex2;
    a(w,w,d,w,d,w) = flex2;
    a(w,w,w,d,d,w) = flex2;

    a(w,c,w,w,w,w) = FLEX1;
    a(w,w,c,w,w,w) = FLEX1;
    a(w,w,w,c,w,w) = FLEX1;
    a(w,w,w,w,c,w) = FLEX1;

    a(w,d,w,w,w,w) = flex1;
    a(w,w,d,w,w,w) = flex1;
    a(w,w,w,d,w,w) = flex1;
    a(w,w,w,w,d,w) = flex1;

    %x:左5中黑个数,y:左5中白个数,ix:右5中黑个数,iy:右5中白个数
    %x:左5中color个数,y:左5中-color个数,ix:右5中color个数,iy:右5中-color个数
    for p1=1:4
        for p2=1:3
            for p3=1:3
                for p4=1:3
                    for p5=1:3
                        for p6=1:4
                            x = 0;
                            y = 0;
                            ix = 0;
                            iy = 0;
                            if p1==c
                                x = x+1;
                            elseif p1==d
                                y = y+1;
                            end
                            if p2==c
                                x = x+1;
                                ix = ix+1;
                            elseif p2==d
                                y = y+1;
                                iy = iy+1;
                            end
                            if p3==c
                                x = x+1;
                                ix = ix+1;
                            elseif p3==d
                                y = y+1;
                                iy = iy+1;
                            end
                            if p4==c
                                x = x+1;
                                ix = ix+1;
                            elseif p4==d
                                y = y+1;
                                iy = iy+1;
                            end
                            if p5==c
                                x = x+1;
                                ix = ix+1;
                            elseif p5==d
                                y = y+1;
                                iy = iy+1;
                            end 
                            if p6==c
                                ix = ix+1;
                            elseif p6==d
                                iy = iy+1;
                            end

                            if p1==u || p6==u
                                if p1==u && p6~=u
                                    if ix==4 && iy==0 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = BLOCK4;
                                    end
                                    if ix==0 && iy==4 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = block4;
                                    end
                                    if ix==3 && iy==0 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = BLOCK3;
                                    end
                                    if ix==0 && iy==3 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = block3;
                                    end
                                    if ix==2 && iy==0 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = BLOCK2;
                                    end
                                    if ix==0 && iy==2 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = block2;
                                    end
                                elseif p1~=u && p6==u
                                    if x==4 && y==0 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = BLOCK4;
                                    end
                                    if x==0 && y==4 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = block4;
                                    end
                                    if x==3 && y==0 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = BLOCK3;
                                    end
                                    if x==0 && y==3 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = block3;
                                    end
                                    if x==2 && y==0 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = BLOCK2;
                                    end
                                    if x==0 && y==2 && a(p1,p2,p3,p4,p5,p6) == 0
                                        a(p1,p2,p3,p4,p5,p6) = block2;
                                    end
                                end
                            else
                                if ((x==4 && y==0)||(ix==4 && iy==0)) && a(p1,p2,p3,p4,p5,p6) == 0
                                    a(p1,p2,p3,p4,p5,p6) = BLOCK4;
                                end
                                if ((x==0 && y==4)||(ix==0 && iy==4)) && a(p1,p2,p3,p4,p5,p6) == 0
                                    a(p1,p2,p3,p4,p5,p6) = block4;
                                end
                                if ((x==3 && y==0)||(ix==3 && iy==0)) && a(p1,p2,p3,p4,p5,p6) == 0
                                    a(p1,p2,p3,p4,p5,p6) = BLOCK3;
                                end
                                if ((x==0 && y==3)||(ix==0 && iy==3)) && a(p1,p2,p3,p4,p5,p6) == 0
                                    a(p1,p2,p3,p4,p5,p6) = block3;
                                end
                                if ((x==2 && y==0)||(ix==2 && iy==0)) && a(p1,p2,p3,p4,p5,p6) == 0
                                    a(p1,p2,p3,p4,p5,p6) = BLOCK2;
                                end
                                if ((x==0 && y==2)||(ix==0 && iy==2)) && a(p1,p2,p3,p4,p5,p6) == 0
                                    a(p1,p2,p3,p4,p5,p6) = block2;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function value = get_value(board,color,board_size,table)
    c = 1; % node.color
    d = 2; % -node.color
    w = 3; % 0
    u = 4; % 边界
    b = zeros(board_size+2,board_size+2);
    b(1,:) = u;
    b(board_size+2,:) = u;
    b(:,1) = u;
    b(:,board_size+2) = u;
    for i=1:board_size
        for j=1:board_size
            if board(i,j) == color
                b(i+1,j+1) = c;
            elseif board(i,j) == -color
                b(i+1,j+1) = d;
            else
                b(i+1,j+1) = w;
            end
        end
    end
    value = 0;

    for i=1:board_size
        for j=1:board_size-3
            value = value + table(b(i,j),b(i,j+1),b(i,j+2),b(i,j+3),b(i,j+4),b(i,j+5));
        end
    end

    for i=1:board_size-3
        for j=1:board_size
            value = value + table(b(i,j),b(i+1,j),b(i+2,j),b(i+3,j),b(i+4,j),b(i+5,j));
        end
    end

    for i=1:board_size-3
        for j=1:board_size-3
            value = value + table(b(i,j),b(i+1,j+1),b(i+2,j+2),b(i+3,j+3),b(i+4,j+4),b(i+5,j+5));
        end
    end 

    for i=6:board_size+2
        for j=1:board_size-3
            value = value + table(b(i,j),b(i-1,j+1),b(i-2,j+2),b(i-3,j+3),b(i-4,j+4),b(i-5,j+5));
        end
    end 
end

function ret = minimax_func(minimax,game,node,board_size,root_color,depth,table)
    if game.done
        node.value = Inf*game.winner*root_color;
        ret.minimax = minimax;
        ret.value = node.value;
        return
    end
    if node.depth == depth
        node.value = get_value(game.board,root_color,board_size,table);
        ret.minimax = minimax;
        ret.value = node.value;
        return
    end
    valids = seek_points(game.board,game.current_player,board_size,table);
    if node.depth == 0
        minimax.best_x = valids(1,1);
        minimax.best_y = valids(1,2);
    end
    length = size(valids,1);
    for i=1:length
        x = valids(i,1);
        y = valids(i,2);
        temp_game = step(game,board_size,x,y);
        if node.search_type == 1
            next_value = Inf;
        else
            next_value = -Inf;
        end
        subNode = new_node(node.depth+1,-node.search_type,node.alpha,node.beta,next_value);
        ret = minimax_func(minimax,temp_game,subNode,board_size,root_color,depth,table);
        minimax = ret.minimax;
        utility = ret.value;
        if node.depth == 0
            if utility > minimax.max_value
                minimax.max_value = utility;
                minimax.best_x = x;
                minimax.best_y = y;
            end
        end
        if node.search_type == 1
            node.value = max(node.value,utility);
            if node.value >= node.beta
                ret.minimax = minimax;
                ret.value = node.value;
                return
            end
            node.alpha = max(node.value,node.alpha);
        else
            node.value = min(node.value,utility);
            if node.value <= node.alpha
                ret.minimax = minimax;
                ret.value = node.value;
                return
            end
            node.beta = min(node.value,utility);
        end
    end
    ret.minimax = minimax;
    ret.value = node.value;
end

%Minimax&alpha-beta剪枝下棋
function [x,y] = get_action_minimax(game,depth,board_size,table)
    minimax = new_minimax();
    root = new_node(0,1,-Inf,Inf,-Inf);
    ret = minimax_func(minimax,game,root,board_size,game.current_player,depth,table);
    minimax = ret.minimax;
    x = minimax.best_x;
    y = minimax.best_y;
end


%此函数为库函数的修改，仅将十字光标改为箭头光标，改动位置为第88行
function [out1,out2,out3] = ginput_pointer(arg1)
%GINPUT Graphical input from mouse.
%  [X,Y] = GINPUT(N) gets N points from the current axes and returns
%  the X- and Y-coordinates in length N vectors X and Y. The cursor
%  can be positioned using a mouse. Data points are entered by pressing
%  a mouse button or any key on the keyboard except carriage return,
%  which terminates the input before N points are entered.
%
%  [X,Y] = GINPUT gathers an unlimited number of points until the
%  return key is pressed.
%
%  [X,Y,BUTTON] = GINPUT(N) returns a third result, BUTTON, that
%  contains a vector of integers specifying which mouse button was
%  used (1,2,3 from left) or ASCII numbers if a key on the keyboard
%  was used.
%
%  Examples:
%    [x,y] = ginput;
%
%    [x,y] = ginput(5);
%
%    [x, y, button] = ginput(1);
%
%  See also GTEXT, WAITFORBUTTONPRESS.
  
%  Copyright 1984-2011 The MathWorks, Inc.
%  $Revision: 5.32.4.18 $ $Date: 2011/05/17 02:35:09 $
  
out1 = []; out2 = []; out3 = []; y = [];
c = computer;
if ~strcmp(c(1:2),'PC')
  tp = get(0,'TerminalProtocol');
else
  tp = 'micro';
end
  
if ~strcmp(tp,'none') && ~strcmp(tp,'x') && ~strcmp(tp,'micro'),
  if nargout == 1,
    if nargin == 1,
      out1 = trmginput(arg1);
    else
      out1 = trmginput;
    end
  elseif nargout == 2 || nargout == 0,
    if nargin == 1,
      [out1,out2] = trmginput(arg1);
    else
      [out1,out2] = trmginput;
    end
    if nargout == 0
      out1 = [ out1 out2 ];
    end
  elseif nargout == 3,
    if nargin == 1,
      [out1,out2,out3] = trmginput(arg1);
    else
      [out1,out2,out3] = trmginput;
    end
  end
else
   
  fig = gcf;
  figure(gcf);
   
  if nargin == 0
    how_many = -1;
    b = [];
  else
    how_many = arg1;
    b = [];
    if ischar(how_many) ...
        || size(how_many,1) ~= 1 || size(how_many,2) ~= 1 ...
        || ~(fix(how_many) == how_many) ...
        || how_many < 0
      error(message('MATLAB:ginput:NeedPositiveInt'))
    end
    if how_many == 0
      % If input argument is equal to zero points,
      % give a warning and return empty for the outputs.
       
      warning (message('MATLAB:ginput:InputArgumentZero'));
    end
  end
   
  % Setup the figure to disable interactive modes and activate pointers. 
  initialState = setupFcn(fig);
  set(gcf, 'pointer', 'arrow');
   
  % onCleanup object to restore everything to original state in event of
  % completion, closing of figure errors or ctrl+c. 
  c = onCleanup(@() restoreFcn(initialState));
     
   
  % We need to pump the event queue on unix
  % before calling WAITFORBUTTONPRESS
  drawnow
  char = 0;
   
  while how_many ~= 0
    % Use no-side effect WAITFORBUTTONPRESS
    waserr = 0;
    try
      keydown = wfbp;
    catch %#ok<CTCH>
      waserr = 1;
    end
    if(waserr == 1)
      if(ishghandle(fig))
        cleanup(c);
        error(message('MATLAB:ginput:Interrupted'));
      else
        cleanup(c);
        error(message('MATLAB:ginput:FigureDeletionPause'));
      end
    end
    % g467403 - ginput failed to discern clicks/keypresses on the figure it was
    % registered to operate on and any other open figures whose handle
    % visibility were set to off
    figchildren = allchild(0);
    if ~isempty(figchildren)
      ptr_fig = figchildren(1);
    else
      error(message('MATLAB:ginput:FigureUnavailable'));
    end
    %     old code -> ptr_fig = get(0,'CurrentFigure'); Fails when the
    %     clicked figure has handlevisibility set to callback
    if(ptr_fig == fig)
      if keydown
        char = get(fig, 'CurrentCharacter');
        button = abs(get(fig, 'CurrentCharacter'));
      else
        button = get(fig, 'SelectionType');
        if strcmp(button,'open')
          button = 1;
        elseif strcmp(button,'normal')
          button = 1;
        elseif strcmp(button,'extend')
          button = 2;
        elseif strcmp(button,'alt')
          button = 3;
        else
          error(message('MATLAB:ginput:InvalidSelection'))
        end
      end
      axes_handle = gca;
      drawnow;
      pt = get(axes_handle, 'CurrentPoint');
       
      how_many = how_many - 1;
       
      if(char == 13) % & how_many ~= 0)
        % if the return key was pressed, char will == 13,
        % and that's our signal to break out of here whether
        % or not we have collected all the requested data
        % points.
        % If this was an early breakout, don't include
        % the <Return> key info in the return arrays.
        % We will no longer count it if it's the last input.
        break;
      end
       
      out1 = [out1;pt(1,1)]; %#ok<AGROW>
      y = [y;pt(1,2)]; %#ok<AGROW>
      b = [b;button]; %#ok<AGROW>
    end
  end
   
  % Cleanup and Restore 
  cleanup(c);
   
  if nargout > 1
    out2 = y;
    if nargout > 2
      out3 = b;
    end
  else
    out1 = [out1 y];
  end
   
end
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function key = wfbp
%WFBP  Replacement for WAITFORBUTTONPRESS that has no side effects.
  
fig = gcf;
current_char = []; %#ok<NASGU>
  
% Now wait for that buttonpress, and check for error conditions
waserr = 0;
try
  h=findall(fig,'Type','uimenu','Accelerator','C');  % Disabling ^C for edit menu so the only ^C is for
  set(h,'Accelerator','');              % interrupting the function.
  keydown = waitforbuttonpress;
  current_char = double(get(fig,'CurrentCharacter')); % Capturing the character.
  if~isempty(current_char) && (keydown == 1)     % If the character was generated by the
    if(current_char == 3)              % current keypress AND is ^C, set 'waserr'to 1
      waserr = 1;                 % so that it errors out.
    end
  end
   
  set(h,'Accelerator','C');              % Set back the accelerator for edit menu.
catch %#ok<CTCH>
  waserr = 1;
end
drawnow;
if(waserr == 1)
  set(h,'Accelerator','C');             % Set back the accelerator if it errored out.
  error(message('MATLAB:ginput:Interrupted'));
end
if nargout>0, key = keydown; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
function initialState = setupFcn(fig)
% Store Figure Handle. 
initialState.figureHandle = fig; 
% Suspend figure functions
initialState.uisuspendState = uisuspend(fig);
% Disable Plottools Buttons
initialState.toolbar = findobj(allchild(fig),'flat','Type','uitoolbar');
if ~isempty(initialState.toolbar)
  initialState.ptButtons = [uigettool(initialState.toolbar,'Plottools.PlottoolsOff'), ...
    uigettool(initialState.toolbar,'Plottools.PlottoolsOn')];
  initialState.ptState = get (initialState.ptButtons,'Enable');
  set (initialState.ptButtons,'Enable','off');
end
% Setup FullCrosshair Pointer without warning. 
oldwarnstate = warning('off', 'MATLAB:hg:Figure:Pointer');
set(fig,'Pointer','fullcrosshair');
warning(oldwarnstate);
% Adding this to enable automatic updating of currentpoint on the figure 
set(fig,'WindowButtonMotionFcn',@(o,e) dummy());
% Get the initial Figure Units
initialState.fig_units = get(fig,'Units');
end
function restoreFcn(initialState)
if ishghandle(initialState.figureHandle)
  % Figure Units
  set(initialState.figureHandle,'Units',initialState.fig_units);
  set(initialState.figureHandle,'WindowButtonMotionFcn','');
   
  % Plottools Icons
  if ~isempty(initialState.toolbar) && ~isempty(initialState.ptButtons)
    set (initialState.ptButtons(1),'Enable',initialState.ptState{1});
    set (initialState.ptButtons(2),'Enable',initialState.ptState{2});
  end
   
  % UISUSPEND
  uirestore(initialState.uisuspendState);
end
end
function dummy()
% do nothing, this is there to update the GINPUT WindowButtonMotionFcn. 
end
function cleanup(c)
if isvalid(c)
  delete(c);
end
end
