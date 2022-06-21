%{
# 
virus_nickname              : varchar(16)                   # 
virus_id                    : int                           # virus count of the same type
---
virus_fullname              : varchar(64)                   # 
-> reference.VirusType
-> reference.VirusSource
catlog_number               : varchar(64)                   # 
titer                       : float                         # 10^12 geno copies per mL
date_came_in=null           : date                          # 
virus_description           : varchar(512)                  # 
%}


classdef Virus < dj.Lookup
    properties
        contents = {
            'jRCaMP1a', 1, 'AAV1.Syn.NES.jRCaMP1a.WPRE.SV40', 'AAV', 'Upenn', '', 33.6, '', ''
            'GCaMP6f', 1, 'AAV1.Syn.GCaMP6f.WPRE.SV40', 'AAV', 'UPenn', '', 26.5, '', '' 
            'Syn.RFP', 1, 'AAV5.hSyn.TurboRFP.WPRE.rBG', 'AAV', 'UPenn', '', 44, '', '' 
            'GFAP.GFP', 1, 'AAV5.GFAP.eGFP.WPRE.hGH', 'AAV', 'UPenn', '', 10.6, '', '' 
            'CamKII.GFP', 1, 'AAV9.CamKII0.4.eGFP.WPRE.rBG', 'AAV', 'UPenn', '', 34.9, '', '' 
            'Syn.RFP', 1, 'AAV9.hSyn.TurboRFP.WPRE.rBG', 'AAV', 'UPenn', '', 66.4, '', '' 
            'ChR2(H134R)-YFP', 1, 'AAV9.hSyn.hChR2(H134R)-eYFP.WPRE.hGH', 'AAV', 'UPenn', '', 33.9, '', '' 
            'Chronos-GFP', 1, 'AAV9.Syn.Chronos-GFP.WPRE.bGH', 'AAV', 'UPenn', '', 35.1, '', ''
        }
    end
end
