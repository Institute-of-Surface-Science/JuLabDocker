FROM ubuntu:20.04

# Set timezone
ARG TIMEZONE=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

# Install software from ubuntu
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget tzdata apt-utils software-properties-common \
    bzip2 sudo curl vim libssl-dev git-all cmake build-essential gcc-10 g++-10 gfortran-10 \
    clang-10 libboost-all-dev libopenmpi-dev libparmetis-dev libparmetis4.0 libsuitesparse-dev \
    libmumps-dev libmumps-ptscotch-dev libmumps-scotch-dev libgmp3-dev libmpfr-dev libmpfr-doc \
    libmpfr6 libhypre-dev petsc-dev libxml2-dev pkg-config python3-mpi4py keyboard-configuration \
    paraview paraview-dev vtk7 libhdf5-dev hdf5-tools gpaw gpaw-data lammps lammps-data lammps-examples \
    liblammps-dev python3-pip paraview

# install from none standard repos
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes intel-mkl-full
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs
RUN apt-add-repository ppa:cantera-team/cantera && apt-get install -y cantera-python3 cantera-dev cantera-common

# install JULIA
RUN curl -fsSL https://install.julialang.org | sh -s -- -y
ENV PATH="/root/.julia/juliaup:$PATH"

