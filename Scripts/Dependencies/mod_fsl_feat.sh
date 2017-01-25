
sed -i -e 's/***OUTPUT_DIR/'$OUTPUT_DIR'/g' ppi_feat_template.fsf

sed -i -e 's/***TR_in_sec/'$TR'/g' ppi_feat_template.fsf

sed -i -e 's/***NUM_VOLs/'$NUM_VOLs'/g' ppi_feat_template.fsf

sed -i -e 's/***DEL_VOLs/'$DEL_VOLs'/g' ppi_feat_template.fsf

sed -i -e 's/***FUN_DATA/'$FUN_DATA'/g' ppi_feat_template.fsf

sed -i -e 's/***TASK_TSERIES/'$TASK_TSERIES'/g' ppi_feat_template.fsf

sed -i -e 's/***ROI_TSERIES/'$ROI_TSERIES'/g' ppi_feat_template.fsf