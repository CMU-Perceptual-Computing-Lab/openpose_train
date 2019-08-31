function [keypoints, skeleton, key_trans] = getKeypointsLabelsAndSkeleton(bodypart)
% Returns keypoint labels / transformations and skeleton for hands or face.
% Index starts at 1. Skeleton need to be 0-adjusted.
% See bottom for meaning of keypoint statuses (0-3).
%
% Haroon Idrees

keypoints = [];
skeleton = []; % not defined here
key_trans = []; % keypoint transformation [old, new]; not defined

if strcmp(bodypart, 'hands')
    % Hand keypoint abbreviations
    % CMC: Carpometacarpal joint (near knuckle)
    % MCP: Metacarpophalaneal joint (finger center)
    % IP: Interphalangeal joint (next to finger tip)
    
    keypoints{1} = 'Left Wrist';
    keypoints{2} = 'Left Thumb CMC';
    keypoints{3} = 'Left Thumb MCP';
    keypoints{4} = 'Left Thumb IP';
    keypoints{5} = 'Left Thumb Tip';
    keypoints{6} = 'Left Index CMC';
    keypoints{7} = 'Left Index MCP';
    keypoints{8} = 'Left Index IP';
    keypoints{9} = 'Left Index Tip';
    keypoints{10} = 'Left Middle CMC';
    keypoints{11} = 'Left Middle MCP';
    keypoints{12} = 'Left Middle IP';
    keypoints{13} = 'Left Middle Tip';
    keypoints{14} = 'Left Ring CMC';
    keypoints{15} = 'Left Ring MCP';
    keypoints{16} = 'Left Ring IP';
    keypoints{17} = 'Left Ring Tip';
    keypoints{18} = 'Left Small CMC';
    keypoints{19} = 'Left Small MCP';
    keypoints{20} = 'Left Small IP';
    keypoints{21} = 'Left Small Tip';
    keypoints{22} = 'Right Wrist';
    keypoints{23} = 'Right Thumb CMC';
    keypoints{24} = 'Right Thumb MCP';
    keypoints{25} = 'Right Thumb IP';
    keypoints{26} = 'Right Thumb Tip';
    keypoints{27} = 'Right Index CMC';
    keypoints{28} = 'Right Index MCP';
    keypoints{29} = 'Right Index IP';
    keypoints{30} = 'Right Index Tip';
    keypoints{31} = 'Right Middle CMC';
    keypoints{32} = 'Right Middle MCP';
    keypoints{33} = 'Right Middle IP';
    keypoints{34} = 'Right Middle Tip';
    keypoints{35} = 'Right Ring CMC';
    keypoints{36} = 'Right Ring MCP';
    keypoints{37} = 'Right Ring IP';
    keypoints{38} = 'Right Ring Tip';
    keypoints{39} = 'Right Small CMC';
    keypoints{40} = 'Right Small MCP';
    keypoints{41} = 'Right Small IP';
    keypoints{42} = 'Right Small Tip';
    
elseif strcmp(bodypart, 'face')
    keypoints{1} = 'Right Face Ear-Top';
    keypoints{2} = 'Right Face Ear-Middle';
    keypoints{3} = 'Right Face Ear-Bottom';
    keypoints{4} = 'Right Jawline Back (near ear)';
    keypoints{5} = 'Right Jawline Back-Center';
    keypoints{6} = 'Right Jawline Front-Center';
    keypoints{7} = 'Right Jawline Front (near chin)';
    keypoints{8} = 'Right Chin';
    keypoints{9} = 'Chin';
    keypoints{10} = 'Left Chin'; 
    keypoints{11} = 'Left Jawline Front (near chin)';
    keypoints{12} = 'Left Jawline Front-Center';
    keypoints{13} = 'Left Jawline Back-Center';
    keypoints{14} = 'Left Jawline Back (near ear)';
    keypoints{15} = 'Left Face Ear-Bottom';
    keypoints{16} = 'Left Face Ear-Middle';
    keypoints{17} = 'Left Face Ear-Top';
    keypoints{18} = 'Right Eyebrow Outer corner';
    keypoints{19} = 'Right Eyebrow Outer-top';
    keypoints{20} = 'Right Eyebrow Top';
    keypoints{21} = 'Right Eyebrow Inner-top';
    keypoints{22} = 'Right Eyebrow Inner corner';
    keypoints{23} = 'Left Eyebrow Inner corner';
    keypoints{24} = 'Left Eyebrow Inner-Top';
    keypoints{25} = 'Left Eyebrow Top';
    keypoints{26} = 'Left Eyebrow Outer-Top';
    keypoints{27} = 'Left Eyebrow Outer corner';
    keypoints{28} = 'Nose Radix (top)';
    keypoints{29} = 'Nose Rhinion (top-middle)';
    keypoints{30} = 'Nose Supratip (bottom-middle)';
    keypoints{31} = 'Nose Tip (bottom)';
    keypoints{32} = 'Right Nostril Outer';
    keypoints{33} = 'Right Nostril Inner';
    keypoints{34} = 'Nasal Bridge';
    keypoints{35} = 'Left Nostril Inner';
    keypoints{36} = 'Left Nostril Outer';
    keypoints{37} = 'Right Eye Outer corner';
    keypoints{38} = 'Right Eyelid Outer-Top';
    keypoints{39} = 'Right Eyelid Inner-Top';
    keypoints{40} = 'Right Eye Inner';
    keypoints{41} = 'Right Eyelid Inner-Bottom';
    keypoints{42} = 'Right Eyelid Outer-Bottom';
    keypoints{43} = 'Left Eye Inner corner';
    keypoints{44} = 'Left Eyelid Inner-Top';
    keypoints{45} = 'Left Eyelid Outer-Top';
    keypoints{46} = 'Left Eye Outer corner';
    keypoints{47} = 'Left Eyelid Outer-Bottom';
    keypoints{48} = 'Left Eyelid Inner-Bottom';
    keypoints{49} = 'Right Oral Commissure';
    keypoints{50} = 'Upper Lip Vermillion Border Right';
    keypoints{51} = 'Upper Lip Right-Philtrum';
    keypoints{52} = 'Cupid''s Bow';
    keypoints{53} = 'Upper Lip Left-Philtrum';
    keypoints{54} = 'Upper Lip Vermillion Border Left';
    keypoints{55} = 'Left Oral Commissure';
    keypoints{56} = 'Lower Lip Vermillion Border Left';
    keypoints{57} = 'Lower Lip Vermillion Border Left-Center';
    keypoints{58} = 'Lower Lip Vermillion Border Center';
    keypoints{59} = 'Lower Lip Vermillion Border Right-Center';
    keypoints{60} = 'Lower Lip Vermillion Border Right';
    keypoints{61} = 'Oral Fissue Left';
    keypoints{62} = 'Oral Fissure Top-Right';
    keypoints{63} = 'Oral Fissure Top-Center';
    keypoints{64} = 'Oral Fissure Top-Left';
    keypoints{65} = 'Oral Fissure Right';
    keypoints{66} = 'Oral Fissure Bottom-Left';
    keypoints{67} = 'Oral Fissure Bottom-Center';
    keypoints{68} = 'Oral Fissure Bottom-Right';
    keypoints{69} = 'Unlabeled';
    keypoints{70} = 'Unlabeled';
    
end

% keypoint status meaning
% 2: labeled
% 3: unlabeled






