echo $(pwd)

source /home/u19prod@pu.win.princeton.edu/.bashrc
source /home/u19prod@pu.win.princeton.edu/.bash_profile

cd "/home/u19prod@pu.win.princeton.edu/Datajoint_projs/U19-pipeline-matlab/"
git pull
matlab -nodisplay -nosplash -nodesktop -batch "run 'scripts/startup_virtual_machine.m'; run 'scripts/populate_tables.m';"
