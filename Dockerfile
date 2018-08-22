## Emacs, make this -*- mode: sh; -*-
 
FROM centos:6.8

COPY . /app
WORKDIR /app

RUN echo "LANG=en_US.utf8" >> /etc/locale.conf && \
	localedef -c -f UTF-8 -i en_US en_US.UTF-8 && \
	export LC_ALL=en_US.UTF-8

#安装R语言包依赖的系统库
RUN	yum -y install wget make bzip2-devel gcc-c++ gcc-gfortran libX11-devel libicu-devel libxml2 \
  	libxml2-devel openssl-devel pcre-devel pkgconfig tcl-devel texinfo-tex tk-devel tre-devel \
  	xz-devel zlib-devel bzip2-libs cpp expat-devel fontconfig-devel freetype-devel \
  	gcc glib2 glibc-devel glibc-headers kernel-headers libX11 libXau libXau-devel libXft-devel \
  	libXrender-devel libffi libgcc libicu libmpc libquadmath-devel libselinux libsepol libstdc++ \
  	libstdc++-devel libxcb libxcb-devel mpfr pcre perl perl-Data-Dumper perl-Text-Unidecode \
  	libgfortran libgomp freetype fontconfig libXrender libpng pango-devel.x86_64 libXt-devel \
  	cairo-devel.x86_64 NLopt-devel.x86_64 curl.x86_64 postgresql-devel \
  	libcurl-devel mesa-libGL-devel mesa-libGLU-devel mysql-devel \
  	openssh-server openssh-clients openssh httpd gsl-devel readline-devel \
  	perl-libintl texinfo texlive-epsf xorg-x11-proto-devel xz-libs xz-devel.x86_64 zlib which && \
   	yum groupinstall X11 -y && \
  	yum clean all

#下载JDK
RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm

RUN yum -y install /tmp/jdk-8-linux-x64.rpm

RUN alternatives --install /usr/bin/java jar /usr/java/latest/bin/java 200000 && \
	alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000 && \
	alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000 && \
	rm -fr /tmp/jdk-8-linux-x64.rpm

#设置JAVA环境变量
ENV JAVA_HOME /usr/java/latest
ENV PATH $PATH:$JAVA_HOME/bin

#下载R-3.3.3源码并编译安装
RUN wget https://cran.r-project.org/src/base/R-3/R-3.3.3.tar.gz && \
  	tar -zxvf R-3.3.3.tar.gz && \
  	cd R-3.3.3 && \
  	./configure --prefix=/usr/local/lib64/R --with-readline=yes --with-x=yes --enable-R-shlib && \
  	make && make install && \
  	rm -fr R-3.3.3.tar.gz && rm -fr R-3.3.3

#设置R环境变量
ENV R_HOME /usr/local/lib64/R
ENV PATH $PATH:$R_HOME/bin

# install need packages
RUN R -e "install.packages(c('littler','stringr','acepack','adabag','amap','arules','arulesSequences','assertthat','backports','base','base64enc','BH','bindr','bindrcpp','bit','bit64','bitops','blob','bnlearn','boot','Cairo','car','caret','checkmate','chron','class','cluster','codetools','coin','colorspace','combinat','compiler','config','crayon','crosstalk','curl','CVST','datasets','data.table','DBI','ddalpha','debugme','DEoptimR','diagram','dichromat','digest','dimRed','diptest','DistributionUtils','dplyr','DRR','dtw','dygraphs','e1071','evaluate','expm','fArma','fBasics','flexmix','fmsb','FNN','foreach','forecast','foreign','Formula','fpc','fracdiff','fUnitRoots','futile.logger','futile.options','gbm','GeneralizedHyperbolic','ggfortify','ggplot2','glmnet','glue','gower','graphics','grDevices','grid','gridExtra','gss','gsubfn','gtable','hexbin','highr','Hmisc','htmlTable','htmltools','htmlwidgets','httpuv','httr','igraph','ipred','irlba','iterators','jiebaR','jiebaRD','jsonlite','keras','kernlab','KernSmooth','kknn','klaR','knitr','ks','labeling','lambda.r','lattice','latticeExtra','lava','lazyeval','lda','leaps','lme4','lmtest','locfit','log4r','lubridate','magrittr','markdown','MASS','Matrix','MatrixModels','mclust','memoise','methods','mgcv','mime','minqa','misc3d','mlbench','ModelMetrics','modeltools','multcomp','multicool','munsell','mvtnorm','nlme','nloptr','NLP','nnet','nortest','numDeriv','openssl','parallel','party','pbkrtest','pkgconfig','plogr','plotly','plotrix','pls','plspm','plyr','prabclus','pracma','pROC','processx','prodlim','proto','proxy','purrr','qcc','quadprog','quantmod','quantreg','R2HTML','R6','randomForest','RColorBrewer','Rcpp','RcppArmadillo','RcppArmadillo-bak','RcppEigen','RcppRoll','RCurl','recipes','recommenderlab','registry','reshape','reshape2','reticulate','rgl','ridge','rJava','RJDBC','rlang','RMySQL','RMySQL-bak','robustbase','rpart','RPostgreSQL','Rserve','RSNNS','Rsolnp','RSQLite','rstudioapi','rugarch','RUnit','Rwordseg','sandwich','scales','shape','shiny','showtext','showtextdb','SkewHyperbolic','slam','SnowballC','sourcetools','SparseM','spatial','spd','splines','splitstackshape','sqldf','stabledist','stats','stats4','stringi','stringr','strucchange','survival','sysfonts','tcltk','tensorflow','tester','tfruns','TH.data','tibble','tidyr','tidyselect','timeDate','timeSeries','tm','tmcn','tools','topicmodels','tree','trimcluster','truncnorm','TSA','tseries','TTR','turner','urca','utils','viridis','viridisLite','visNetwork','whisker','withr','xtable','xts','YaleToolkit','yaml','zoo'), repos='https://mirrors.tuna.tsinghua.edu.cn/CRAN/')"

ADD start.sh /usr/local/bin/start.sh
RUN chmod 777 /usr/local/bin/start.sh
CMD /usr/local/bin/start.sh
