FROM ubuntu:16.04
MAINTAINER Domingo Diez <domingo.diez@airbus.com>

USER root

#RUN whoami
#RUN apt-get update
#RUN apt-get install sudo
#RUN echo "ros ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

#ENV USERNAME ros
#RUN adduser --ingroup sudo --disabled-password --gecos "" --shell /bin/bash --home /home/$USERNAME $USERNAME
#RUN bash -c 'echo $USERNAME:ros | chpasswd'
#ENV HOME /home/$USERNAME
#USER $USERNAME

#RUN whoami


RUN apt-get update \
	&& apt-get install wget -y \
	&& apt-get install build-essential -y

RUN apt-get clean

RUN apt-get update \
	&& apt-get install vim -y \
	&& apt-get install git -y \
	&& apt-get install build-essential -y \
	&& apt install software-properties-common -y 


RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
	&& apt-get update \
	&& apt-get install gcc-snapshot -y \
	&& apt-get install gcc-7 g++-7 -y

#RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7.5 10
#RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7.5 10

#RUN update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 20
#RUN update-alternatives --set cc /usr/bin/gcc
#RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 20
#RUN update-alternatives --set c++ /usr/bin/g++

#RUN update-alternatives --config gcc
#RUN update-alternatives --config g++

RUN apt-get install libboost-all-dev -y

RUN wget -qO- "https://cmake.org/files/v3.18/cmake-3.18.2-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local
	#&& apt-get install cmake -y
	#&& apt-get install snapd -y \
	#&& snap install cmake




SHELL ["/bin/bash", "--login", "-c"]

#Create a non-root user
ARG username=dogodi
ARG uid=1000
ARG gid=100
ENV USER $username
ENV UID $uid
ENV GID $gid
ENV HOME /home/$USER

RUN adduser --disabled-password \
	--gecos "Non-root user" \
	--uid $UID \
	--gid $GID \
	--home $HOME \
	$USER

COPY environment.yml /tmp/
RUN chown $UID:$GID /tmp/environment.yml

#COPY entrypoint.sh /usr/local/bin/
#RUN chown $UID:$GID /usr/local/bin/entrypoint.sh && \
	#	chmod u+x /usr/local/bin/entrypoint.sh




USER $USER
#install miniconda
ENV MINICONDA_VERSION 4.8.3
ENV CONDA_DIR $HOME/miniconda3
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py37_$MINICONDA_VERSION-Linux-x86_64.sh -O ~/miniconda.sh && \
	chmod +x ~/miniconda.sh && \
	~/miniconda.sh -b -p $CONDA_DIR && \
	rm ~/miniconda.sh

#make non-activate conda commands available
ENV PATH=$CONDA_DIR/bin:$PATH

#make conda activate command available from /bin/bash --login shells
RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc

#make conda activate command available from /bin/bash --interactive
RUN conda init bash

#create a project directory inside user home
ENV PROJECT_DIR $HOME/skdecide2

RUN mkdir $PROJECT_DIR

WORKDIR $PROJECT_DIR

#build de conda environment
#ENV ENV_PREFIX ${PWD:-.}/env
RUN conda update --name base -y --channel defaults conda && \
	conda env create --file /tmp/environment.yml --force && \
	conda clean --all --yes

#COPY scikit-decide ./scikit-decide
#RUN chown -R $UID:$GID ./scikit-decide 

#SHELL ["conda", "run", "-n", "skdecide2", "/bin/bash", "--login", "-c"] 
#WORKDIR $PROJECT_DIR/scikit-decide
#COPY run.py .
RUN echo "source activate skdecide2" >> ~/.bashrc
ENV PATH=$CONDA_DIR/envs/skdecide2/bin:$PATH


#ENTRYPOINT ["pip", "install", ".[all]"]
#RUN pip install . 
#RUN git submodule update --init --recursive #Hey, look at me
RUN python -m pip install --upgrade pip setuptools wheel 

#RUN pip cache purge

#RUN pip install .[all] --verbose #This line will install following the local setup.py of the scikit-decide, make sure you are at the righ place (look for the line with WORKDIR $PROJECT_DIR/scikit-decide), and the line "Hey, look at me" is ON
RUN pip install scikit-decide[all] --verbose
#RUN pip install --no-binary :all: --install-option="--cpp-extension" --install-option="--cxx-compiler=/usr/bin/g++" .[all] --verbose
#RUN pip install --install-option="--cpp-extension" .[all] --verbose


#ENTRYPOINT ["conda", "run", "-n", "skdecide2", "python", "run.py"]
#ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
#SHELL ["conda", "run", "-n", "skdecide2" ]

#RUN ["/bin/bash", "--login", "-c", "cd /home/Synced/scikit-decide/ && conda install ."]

