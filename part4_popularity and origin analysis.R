library(gplots)
# change working dirctory if needed
SEA=c("Brunei","Cambodia","East Timor","Indonesia","Laos","Malaysia","Myanmar","Philippines","Singapore","Thailand","Vietnam")


# popularity of SEA countries (number of trips to the country)
# before, after and overall

before=readRDS("before cutoff continent matrix.rds")
after=readRDS("after cutoff continent matrix.rds")
overall=readRDS("before n after cutoff continent matrix.rds")

sea.visit.before=colSums(before)[1:11]
sea.visit.after=colSums(after)[1:11]
sea.visit.overall=colSums(overall)[1:11]

mat=cbind(sea.visit.before,sea.visit.after,sea.visit.overall)
mat=mat[order(mat[,3],decreasing=TRUE),]

pdf("visits to SEA countries overall, before and after 2010.pdf",width=10)
textplot(mat)
barplot(mat[,3],col="royalblue",border=NA,las=1,cex.names=0.75,
        main="Overall popularity",ylab="Number of trips",cex.lab=1.5,cex.main=2)
barplot(t(mat[,1:2]),col=c("lightblue","orange"),
        legend=c("before 2010","after 2010"),beside=TRUE,border=NA,las=1,cex.names=0.75,
        main="Popularity before and after 2010",ylab="Number of trips",cex.lab=1.5,
        cex.main=2,args.legend=list(border=NA,cex=1.5))

# significance test of change
# The chi-square test statistic for testing the equality of two multinomial distributions
(Xsq=chisq.test(t(mat[,1:2])))
Xsq$observed
Xsq$expected
textplot(capture.output(Xsq$observed,Xsq$expected,Xsq$p.value),halign="left")
dev.off()
#################################################################
## originating continents, where are people coming from

origin.before=rowSums(before[,1:11])
origin.after=rowSums(after[,1:11])
origin.overall=rowSums(overall[,1:11])

origin.before=origin.before[-c(1:11)]
origin.after=origin.after[-c(1:11)]
origin.overall=origin.overall[-c(1:11)]

mat=cbind(origin.before,origin.after,origin.overall)
mat=mat[order(mat[,3],decreasing=TRUE),]

pdf("origin of trip overall, before and after 2010.pdf",width=10)
textplot(mat)
barplot(mat[,3],col="royalblue",border=NA,las=1,
        main="Overall origin of trips",ylab="Number of trips",cex.lab=1.5,cex.main=2)
barplot(t(mat[,1:2]),col=c("lightblue","orange"),las=1,
        legend=c("before 2010","after 2010"),beside=TRUE,border=NA,
        main="Origin of trips before and after 2010",ylab="Number of trips",cex.lab=1.5,
        cex.main=2,args.legend=list(border=NA,cex=1.5))

# significance test of change
# The chi-square test statistic for testing the equality of two multinomial distributions
(Xsq=chisq.test(t(mat[-7,1:2])))
Xsq$observed
Xsq$expected
textplot(capture.output(Xsq$observed,Xsq$expected,Xsq$p.value),halign="left")
dev.off()                    
