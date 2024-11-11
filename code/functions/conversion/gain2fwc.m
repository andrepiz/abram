function fwc = gain2fwc(G_AD, nbit)
% Convert Analog-to-Digital gain in DN/e- to Full Well Capacity given
% a certain bit depth

fwc = (2^nbit-1)/G_AD;

end