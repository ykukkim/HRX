function [row]=MeanSD_2(v)
row = [];
row(1,:)=round(mean(rmoutliers(v),'omitnan'),3);
row(2,:)=round(std(v,'omitnan'),3);
end
