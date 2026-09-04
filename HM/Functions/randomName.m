function [ParticipantName] = randomName()

% generates random subjectName for participant

Let13 ='BCDFGHJKLMNPQRSTVWXYZ';
Let24 ='AEIOU';

Letter1 = Let13(randi(numel(Let13)));
Letter2 = Let24(randi(numel(Let24)));
Letter3 = Let13(randi(numel(Let13)));
Letter4 = Let24(randi(numel(Let24)));

disp([Letter1,Letter2,Letter3,Letter4,'_',num2str(randi([0,9])),num2str(randi([0,9]))])
ParticipantName = [Letter1,Letter2,Letter3,Letter4,'_',num2str(randi([0,9])),num2str(randi([0,9]))];
end
