%% Stack-of-stars
datapath0='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/PROSTATE/T1TFE1/rn_02052018_1754081_10_2_wip_radial_t1tfeV4.raw';
datapath1='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/BSPIR1/ut_14092017_1537185_7_2_wipt4dbffedceclearV4.raw'; % BSPIR1
datapath2='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/T1SPIR1/ut_28092017_1137425_5_2_wipt4dt1tfespirclearV4.raw'; % T1SPIR1
datapath3='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/T1SPIR2/ut_05042017_1738004_11_2_wipt4dt1ffedceclearV4.raw'; % T1SPIR2
datapath4='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/BSPIR2/ut_28092017_1127415_4_2_wipt4dbtfespirclearV4.raw'; % BSPIR2
datapath5='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/BNOSPIR1/ut_28092017_1122351_3_2_wipt4dbffeclearV4.raw'; % BNOSPIR1
datapath6='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/T1SPIR3/ut_26092017_1515142_9_2_wipt4dt1tfespirclearV4.raw'; % T1SPIR3
datapath7='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/ABDOMEN/BSPIR3/ut_26092017_1523044_10_2_wipt4dbtfedcespirclearV4.raw'; % BSPIR3
%datapath8='/nfs/bsc01/researchData/USER/tbruijne/MR_Data/rn_02052018_1750319_9_2_wip_radial_btfe_spairV4.raw'; % BSPAIR Pelvis
datapath9='/local_scratch2/tbruijne/MRRIDDLE_RECONSTRUCTIONS/PANCREAS/VOLUNTEER_CORSET_ROBIN/RECONFRAME/20_09072018_1402454_4_2_wip_t1_3d_tfe_playV4.lab';
for n=9
    MRRIDDLE(eval(['datapath',num2str(n)]),[],10);
end

%% UTE stack-of-stars
girfpath='/nfs/bsc01/researchData/USER/tbruijne/Projects_Software/GIRFs/girf_u2.mat';
datapath0='/nfs/bsc01/researchData/USER/tbruijne/MR_Data/Internal_data/Radial3D_data/U2/20170926_3D_Abdomen/Scan1/ut_26092017_1534464_12_2_wipt3dgameuteclearV4.raw'; % Golden angle stack-of-stars ute
for n=0:0
    MRRIDDLE_UTE(eval(['datapath',num2str(n)]),[],girfpath,5);
end