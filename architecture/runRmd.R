args <- commandArgs(TRUE)
setwd(args[1])
filename<-args[2]
rmarkdown::render(args[2], params = list(clientid = args[3], Year = args[4], Month = args[5], currency = args[6], to_divide = args[7], startMonth = args[8],endMonth = args[9], prefix = args[10]))
 
 