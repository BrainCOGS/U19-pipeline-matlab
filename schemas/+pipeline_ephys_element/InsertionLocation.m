%{
# Brain Location of a given probe insertion.
-> pipeline_ephys_element.ProbeInsertion
---
-> reference.SkullReference
ap_location                 : decimal(6,2)                  # (um) anterior-posterior; ref is 0; more anterior is more positive
ml_location                 : decimal(6,2)                  # (um) medial axis; ref is 0 ; more right is more positive
depth                       : decimal(6,2)                  # (um) manipulator depth relative to surface of the brain (0); more ventral is more negative
theta=null                  : decimal(5,2)                  # (deg) - elevation - rotation about the ml-axis [0, 180] - w.r.t the z+ axis
phi=null                    : decimal(5,2)                  # (deg) - azimuth - rotation about the dv-axis [0, 360] - w.r.t the x+ axis
beta=null                   : decimal(5,2)                  # (deg) rotation about the shank of the probe [-180, 180] - clockwise is increasing in degree - 0 is the probe-front facing anterior
%}


classdef InsertionLocation < dj.Manual


end


