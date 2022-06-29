%{
# Defined optogenetic protocols for training
optogenetic_protocol_id     : int AUTO_INCREMENT            # 
---
protocol_description        : varchar(256)                  # string that describes stimulation protocol
-> [nullable] optogenetics.OptogeneticStimulationParameter
-> [nullable] optogenetics.OptogeneticWaveform
%}

classdef OptogeneticProtocol < dj.Manual    
end
