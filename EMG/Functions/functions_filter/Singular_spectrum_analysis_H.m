function [SSA_data] = Singular_spectrum_analysis_H(data, fs)

for i = size(data,2)
    %% Set general Parameters
    M = fs;
    N = length(data(:,i));
    X = data(:,i);
    t = (1:N)';
    %
    % figure(1);
    % set(gcf,'name','Time series X');
    % clf;
    % plot(t,X,'b-');

    %% Calculate covariance matrix C (Toeplitz approach)
    covX = xcorr(X,M-1,'unbiased');
    Ctoep=toeplitz(covX(M:end));

    % figure(2);
    % set(gcf,'name','Covariance matrix');
    % clf;
    % imagesc(Ctoep);
    % axis square
    % set(gca,'clim',[-1 1]);
    % colorbar

    % This is not applicable for a larget dataset e.g. EMG data for
    % H-reflex project
    %         Y=zeros(N-M+1,M);
    %     for m=1:M
    %         Y(:,m) = X((1:N-M+1)+m-1);
    %     end
    %     Cemb=Y'*Y / (N-M+1);

    % figure(2);
    % set(gcf,'name','Covariance matrix');
    % clf;
    % imagesc(Cemb);
    % axis square
    % set(gca,'clim',[-1 1]);
    % colorbar
    %% Calculate eigenvalues LAMBDA and eigenvectors RHO from Covariance
    % https://uwemeding.com/wp-content/uploads/2013/10/pca.pdf
    C = Ctoep;
    r = 4;
    %     C = Cemb;
    [RHO,LAMBDA] = eig(C);
    LAMBDA = diag(LAMBDA);               % extract the diagonal elements
    [LAMBDA,ind]=sort(LAMBDA,'descend'); % sort eigenvalues
    RHO = RHO(:,ind);                    % and eigenvectors

%     figure(3);
%     set(gcf,'name','Eigenvectors RHO and eigenvalues LAMBDA')
%     clf;
%     subplot(3,1,1);
%     plot(LAMBDA,'o-');
%     subplot(3,1,2);
%     plot(RHO(:,1:2), '-');
%     legend('1', '2');
%     subplot(3,1,3);
%     plot(RHO(:,3:4), '-');
%     legend('3', '4');

    %% Calculate principal components PC
    %     PC = Y*RHO;
    PC = LAMBDA .* RHO;
    figure(4);
    set(gcf,'name','Principal components PCs')
    clf;
    for m=1:4
        subplot(4,1,m);
        %       plot(t(1:N-M+1),PC(:,m),'k-');
        plot(PC(:,m),'k-');
        ylabel(sprintf('PC %d',m));
        ylim([-10 10]);
    end

    %% Calculate reconstructed components RC
    RC=zeros(N,M);
    for m=1:M
        buf=PC(:,m)*RHO(:,m)'; % invert projection
        buf=buf(end:-1:1,:);
        for n=1:N % anti-diagonal averaging
            RC(n,m)=mean( diag(buf,-(N-M+1)+n) );
        end
    end

    % figure(5);
    % set(gcf,'name','Reconstructed components RCs')
    % clf;
    % for m=1:4
    %   subplot(4,1,m);
    %   plot(t,RC(:,m),'r-');
    %   ylabel(sprintf('RC %d',m));
    %   ylim([-1 1]);
    % end

    %% Compare reconstruction and original time series
    % figure(6);
    % set(gcf,'name','Original time series X and reconstruction RC')
    % clf;
    % subplot(2,1,1)
    % plot(t,X,'b-',t,sum(RC(:,:),2),'r-');
    % legend('Original','Complete reconstruction');
    %
    % subplot(2,1,2)
    % plot(t,X,'b','LineWidth',2);
    % plot(t,X,'b-',t,sum(RC(:,1:2),2),'r-');
    % legend('Original','Reconstruction with RCs 1-2');

    SSA_data(:,i) = RC(:,1:7);
end
