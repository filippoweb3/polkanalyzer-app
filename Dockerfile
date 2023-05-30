# Use this file to build the image (podman | docker)
# $ docker build -t polkanalyzer-app .

# Get shiny image

FROM rocker/r-base:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    && rm -rf /var/lib/apt/lists/*

# Install required R package dependencies

RUN install.r shiny \
	shinythemes \ 
	shinycssloaders \ 
	plotly \ 
	DT \
	dplyr \
	utils \
	usethis \
	stringdist \
	rjson \
	maps \
	countrycode
		

RUN echo "local(options(shiny.port = 3838, shiny.host = '0.0.0.0'))" > /usr/lib/R/etc/Rprofile.site

# Copy & install R package

COPY Polkanalyzer_0.0.0.9000.tar.gz /home/

RUN R -e 'install.packages("/home/Polkanalyzer_0.0.0.9000.tar.gz", repos = NULL, type = "source")'

WORKDIR /home/App

COPY App .

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/home/App')"]




# To run the container (podman | docker)
# docker run --rm -p 3838:3838 polkanalyzer-app:latest

# Visit http://localhost:3838/


#docker run -it polkanalyzer-app bash
#ll /home
#ll /srv/shiny-server
