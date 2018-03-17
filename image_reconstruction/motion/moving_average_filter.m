function f_d = moving_average_filter(d,w)
% D is resp signal
% w is width of filter

mov_filter=ones(1,w);
for t=1:size(d,2)
    f_d(:,t)=filter(mov_filter, 1, d(:,t));
    f_d(:,t)=abs(f_d(:,t))/max(abs(f_d(:,t)));
    f_d(1:w,t)=mean(f_d(:,t),1);
end


% END
end