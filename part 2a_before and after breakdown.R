## change working directory if needed


load("travelpod corrected.RData")
load("continent information.RData")
load("country matrix_at least 3 trips.RData")
country.continent=read.csv("country-continent pair_at least 3 trips.csv",stringsAsFactors=F)

SEA=c("Brunei","Cambodia","East Timor","Indonesia","Laos","Malaysia","Myanmar","Philippines","Singapore","Thailand","Vietnam")
ctnts1=c(SEA,"Asia\\SEA",ctnts[-1])
countries.new=sort(unique(c(dat$author_country_1,dat$entry_country_1)))

summary(dat$entry_date)
cutoff=as.Date("2010-01-01",format="%Y-%m-%d")
to.date=function(int) as.Date(int,origin="1970-01-01")

## breakdown to before and after cutoff time
segmts=list()
segmts[[1]]=which(dat$entry_date<cutoff)
segmts[[2]]=which(dat$entry_date>=cutoff)
segmts[[3]]=c(segmts[[1]],segmts[[2]])
segmts.name=c("before","after","before n after")

for(ti in 1:3){
  print(ti)
  dat.part=dat[segmts[[ti]],]
  
  mat.country.ti=matrix(0,nrow=length(countries.new),ncol=length(countries.new),dimnames=list(countries.new,countries.new))
  # trip.country=NULL
  
  blogids=unique(dat.part$blogId)
  for(bi in blogids){ # go through entries by blogid
    dat.sub=dat.part[dat.part$blogId==bi,]
    dat.sub=dat.sub[order(dat.sub$entry_date),] # sort blog entries by entry date
    places=c(dat.sub$author_country_1[1],dat.sub$entry_country_1)
    if(sum(SEA %in% unique(places))>0){
#       # number of days spent in each county
#       temp=data.frame(stay.in=dat.sub$entry_country_1,for.days=c(as.numeric(diff(dat.sub$entry_date)),0))
#       temp1=aggregate(temp$for.days,by=list(temp$stay.in),sum)
#       temp2=to.date(sapply(temp1$Group.1,function(x) min(dat.sub$entry_date[dat.sub$entry_country_1==x]),USE.NAMES=FALSE))
#       trip.country=rbind(trip.country,data.frame(author.country=rep(dat.sub$author_country_1[1],nrow(temp1)),blogID=rep(bi,nrow(temp1)),
#                                                  stay.in=temp1$Group.1,for.days=temp1$x+1,date.1st.arrival=temp2))
      
      for(bj in 1:nrow(dat.sub)){ 
        start=places[bj]
        end=places[bj+1]
        if(start!=end){
          x=match(start,rownames(mat.country.ti)) #start country
          y=match(end,colnames(mat.country.ti)) # end country
          mat.country.ti[x,y]=mat.country.ti[x,y]+1
        }
      }
    } else{
      print(paste(c(bi,unique(places)),collapse=","))
    }
  }
  included.in.analysis=match(colnames(mat.country1),colnames(mat.country.ti))
  mat.country.ti=mat.country.ti[included.in.analysis,included.in.analysis]
  
  ### aggregate to larger scale
  n=length(ctnts1)
  mat.country2.ti=matrix(0,nrow=n,ncol=n,dimnames=list(ctnts1,ctnts1))
  country_continent1=country.continent$continent[match(colnames(mat.country.ti),country.continent$country)]
  for(i in 1:n) for(j in 1:n){
    from=which(country_continent1==ctnts1[i])
    to=which(country_continent1==ctnts1[j])
    mat.country2.ti[i,j]=sum(mat.country.ti[from,to])
  }
  saveRDS(mat.country.ti, paste(segmts.name[ti],"cutoff country matrix.rds"))
  saveRDS(mat.country2.ti, paste(segmts.name[ti],"cutoff continent matrix.rds"))
}




