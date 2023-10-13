FROM svchb/mom_ubuntu:v1

# add a pseudo user to get the paths correctly and deactivate passwords to get arround prompts
#RUN adduser --disabled-password --gecos '' ubuntu
#RUN adduser ubuntu sudo
#RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER root
WORKDIR /root/
RUN chmod a+rwx /root/

# install fftw with MPI
RUN wget https://www.fftw.org/fftw-3.3.10.tar.gz && \
    tar -xzf fftw-3.3.10.tar.gz && \
    rm fftw-3.3.10.tar.gz && \
    cd fftw-3.3.10 && \
    ./configure --enable-mpi && \
    make && make install && \
    cd .. && \
    rm -r fftw-3.3.10

WORKDIR /root/build/
RUN git clone https://github.com/mpip/pfft.git && \
    cd pfft && \
    ./bootstrap.sh && ./configure && make && make install

# install sundials
WORKDIR /root/
RUN wget https://github.com/LLNL/sundials/releases/download/v5.7.0/sundials-5.7.0.tar.gz && \
    tar -xzf sundials-5.7.0.tar.gz && \
    mkdir build_sundials && \
    cd build_sundials && \
    cmake ../sundials-5.7.0/ && make && make install && \
    cd .. && rm -rf build_sundials sundials-5.7.0 sundials-5.7.0.tar.gz

# install libeigen
WORKDIR /root/build/
RUN git clone https://gitlab.com/libeigen/eigen.git && \
    cd eigen && git checkout tags/3.3.9 && \
    mkdir ../eigen_build && cd ../eigen_build && \
    CC=gcc-10 CXX=g++-10 cmake ../eigen && make install

RUN pip3 install setuptools pytest

WORKDIR /root/build/
RUN git clone https://github.com/sympy/sympy.git && cd sympy && git pull origin master && pip3 install .

WORKDIR /root/build/

# Install precice
RUN git clone https://github.com/precice/precice/ && \
    cd precice && \
    git checkout tags/v2.2.0 && \
    mkdir ../precice_build && \
    cd ../precice_build && \
    CC=gcc-10 CXX=g++-10 cmake -DCMAKE_CXX_FLAGS=-I\ /usr/lib/petscdir/petsc3.12/x86_64-linux-gnu-real/include/ -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON ../precice && \
    make install -j 4

# Install additional python packages
RUN pip3 install nutils fenics-ffc --upgrade

# Install pybind
RUN wget -nc --quiet https://github.com/pybind/pybind11/archive/v2.2.3.tar.gz && \
    tar -xf v2.2.3.tar.gz && \
    rm v2.2.3.tar.gz && \
    mkdir pybind_build && \
    cd pybind_build && \
    CC=gcc-10 CXX=g++-10 cmake ../pybind11-2.2.3 && \
    make install

# Install fenics
RUN git clone https://bitbucket.org/fenics-project/dolfin && \
    cd dolfin && \
    git checkout tags/2019.1.0.post0

# Install mshr
RUN git clone https://bitbucket.org/fenics-project/mshr && \
    cd mshr && \
    git checkout tags/2019.1.0

# Build and install dolfin
RUN mkdir dolphin_build && \
    cd dolphin_build && \
    CC=gcc-10 CXX=g++-10 cmake -DDOLFIN_ENABLE_SUNDIALS=false ../dolfin && \
    make install && \
    pip3 install ../dolfin/python

# Build and install mshr
RUN mkdir mshr_build && \
    cd mshr_build && \
    CC=gcc-10 CXX=g++-10 cmake ../mshr && \
    make install && \
    pip3 install ../mshr/python

# Install precice python-bindings and fenics-adapter
RUN git clone https://github.com/precice/python-bindings/ && \
    cd python-bindings && \
    git checkout tags/v2.2.0.1 && \
    python3 setup.py install && \
    git clone https://github.com/precice/fenics-adapter ../fenics-adapter && \
    cd ../fenics-adapter && \
    git checkout tags/v1.0.1 && \
    pip3 install .


#todo: install sagemath
#RUN apt-get update
#RUN apt install -y sagemath sagemath-common sagemath-jupyter

RUN pip3 install Cython==0.29.36 tables==3.8.0
RUN pip3 install tensorflow phonopy==2.14.0
RUN pip3 install pyiron-atomistics==0.2.67 pyiron==0.4.7
RUN pip3 install jupyterlab jupyterhub jupyterlab_widgets
#sphinxdft sqsgenerator #needed?
RUN pip3 install scikit-learn pymatgen keras ipyannotations nglview
RUN pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu

#WORKDIR /root/build/
#RUN git clone https://github.com/bmcage/odes.git odes
#WORKDIR /root/build/odes/
#RUN pip3 install .

WORKDIR /root/
RUN rm -r build

RUN echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> /root/.profile
RUN echo 'bash' >> /root/.profile

RUN mkdir /root/notebooks
WORKDIR /root/notebooks
#RUN rm -r -f examples
#RUN git clone http://10.200.87.214/institute-of-surface-science/modeling/platform/examples.git
#RUN git clone http://10.200.87.214/institute-of-surface-science/modeling/Corrosionfracturecoupling.git
#RUN pwd
WORKDIR /root
#RUN jupyter notebook --generate-config --allow-root
RUN jupyter lab --generate-config --allow-root
RUN jupyterhub --generate-config
RUN echo "c.NotebookApp.password = u'sha1:6a3f528eec40:6e896b6e4828f525a6e20e5411cd1c8075d68619'">> /root/.jupyter/jupyter_notebook_config.py

#listen on 8888
EXPOSE 8888


CMD ["jupyter", "lab", "--notebook-dir=/root/notebooks", "--ip='*'", "--port=8888", "--allow-root", "--no-browser"]
