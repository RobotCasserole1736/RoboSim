% circuit_breaker.m
% Circuit Breaker Model
%
%   This contains model a circuit breaker.
%
%   Original scope is for the Series 18X Hi-Amp Circuit Breaker
%   See spec at http://files.andymark.com/PDFs/am-0282_data_sheet.pdf
%
% Created November 11, 2015 - Andrew Gurik
% 

function [o_current, o_state] = circuit_breaker(current_in, cb)

% determine the length of the cusum
history_length = length(cb.history);

% calculate the new value to be added to the cusum (Amps)
new_value = current_in;

% rated current to be used and modified by this model
l_rated_current = cb.rated_current

%% CUSUM update
%increment the cusum pointer
if cb.history_pt >= history_length
  % rollover
  cb.history_pt = 1;
  cb.rollover = 1;
else
  % simple increment
  cb.history_pt = cb.history_pt + 1;
end
% update the accumulation with this loop's current
cb.history(cb.history_pt) = new_value;


%% Evaluate if the breaker should trip.
if new_value > cb.rated_current
  % only do work if the current is above the rated current
  
  % check each map point
  for j = 1:length(cb.time_map)
    n_samples = cb.time_map(i)/Ts; % size of window (loops)
    
    if cb.history_pt >= n_samples
      % create a local history that is the size of the window.
      l_hist = history((history_pt-n_samples):history_pt);
    else if cb.rollover = 1
      % the window is bigger than the number of samples earlier in the array and a rollover has occured.
      % we need to look at all previous and stuff at the end.
      l_hist1 = history(1:history_pt);
      l_hist2 = history((n_samples-history_pt+1):n_samples);
      l_hist=cat(2,l_hist1,l_hist2);
    end
    
    % calculate the average current in the local history
    l_hist_avg = mean(l_hist);
    
    % calculate the threshold
    l_threshold = cb.time_rated_current_map(i)*cb.rated_current/100;
    
    if l_hist_avg > l_threshold
      % if this average current is greater than the corresponding configured current, trip the breaker.
      cb.state = 1;
      break;
    end
  endfor
  
else
  % everything turned out better than expected
end



%% Circuit Breaker logic
if cb.state = 0
  % OK
  o_current = current_in;
else
  % Tripped
  o_current = 0;
end

o_state = cb.state;