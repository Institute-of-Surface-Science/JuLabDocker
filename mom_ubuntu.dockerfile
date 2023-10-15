FROM ubuntu:22.04

# Set timezone
ARG TIMEZONE=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

# Install software from ubuntu
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget tzdata apt-utils software-properties-common \
    bzip2 sudo curl vim libssl-dev git-all cmake build-essential gcc-11 g++-11 gfortran-11 \
    clang-14 libboost-all-dev libopenmpi-dev libparmetis-dev libparmetis4.0 libsuitesparse-dev \
    libmumps-dev libmumps-ptscotch-dev libmumps-scotch-dev libgmp3-dev libmpfr-dev libmpfr-doc \
    libmpfr6 libhypre-dev petsc-dev libxml2-dev pkg-config python3-mpi4py keyboard-configuration \
    paraview paraview-dev vtk7 libhdf5-dev hdf5-tools gpaw gpaw-data lammps lammps-data \
    liblammps-dev python3-pip libfftw3-mpi3 libfftw3-mpi-dev \
    intel-mkl-full && \
    apt-get clean && rm -rf /var/lib/apt/lists/*  # Cleanup cache to reduce layer size

# gets too large
# paraview

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

# Install Cantera
RUN wget -O /tmp/cantera_key.asc "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8B658577822FF0E4CAF2AD557E9FADFA1CFBACEB" && \
    apt-key add /tmp/cantera_key.asc && \
    apt-add-repository "ppa:cantera-team/cantera" && \
    apt-get update && \
    apt-get install -y cantera-python3 cantera-dev cantera-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/cantera_key.asc  # Cleanup cache and remove the key file


# Install JULIA (gets too large)
RUN curl -fsSL https://install.julialang.org | sh -s -- -y
ENV PATH="/root/.julia/juliaup:$PATH"
