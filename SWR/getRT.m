function [RTs] = getRT(cfg)

SPK = makeSPK_create(cfg);
evt = struct(SPK);
eventslabel = evt.eventlabel;
events = evt.events;
events(cellfun(@isempty,events))={nan};

events2 = cell2mat(events(strcmp(eventslabel,'BAR_RELEASE_ON_TEST'),:));
events1 = cell2mat(events(strcmp(eventslabel,'TEST_DIMMED'),:));

RTs = (events2- events1);
RTs(RTs>500) = nan;

switch cfg.type
    case 'raw'
        RTs = RTs;
    case 'zscore'
        RTs = (RTs - nanmean(RTs))/nanstd(RTs,0,2);
    case 'dmean'
        RTs = (RTs - nanmean(RTs));
end
