## change working directory if needed
load("data/travelpod corrected.RData")

##################################################################################
##
##      Store the continent where each country belongs to
##
##################################################################################
countries.new=sort(unique(c(dat$author_country_1,dat$entry_country_1)))
country.info=read.csv("data/country codes from www.geonames.org.csv") ## NA for North America
str(country.info)
ctnts=c("Asia","Europe","Oceania","North America","Africa","South America","Antarctica")
country.info$Continent=ctnts[match(country.info$Continent,c("AS","EU","OC",NA,"AF","SA","AN"))]
save(ctnts,country.info,file="data/continent information.RData")


##################################################################################
##
##      extract inter-country trips and store them in a matrix
##      extract the time people stay in a country
##
##################################################################################
to.date=function(int) as.Date(int,origin="1970-01-01")
mat.country=matrix(0,nrow=length(countries.new),ncol=length(countries.new),dimnames=list(countries.new,countries.new))
trip.country=NULL

blogids=unique(dat$blogId)
for(bi in blogids){ # go through entries by blogid
  dat.sub=dat[dat$blogId==bi,]
  dat.sub=dat.sub[order(dat.sub$entry_date),] # sort blog entries by entry date
  places=c(dat.sub$author_country_1[1],dat.sub$entry_country_1)
  if(sum(SEA %in% unique(places))>0){
    # number of days spent in each county
    temp=data.frame(stay.in=dat.sub$entry_country_1,for.days=c(as.numeric(diff(dat.sub$entry_date)),0))
    temp1=aggregate(temp$for.days,by=list(temp$stay.in),sum)
    temp2=to.date(sapply(temp1$Group.1,function(x) min(dat.sub$entry_date[dat.sub$entry_country_1==x]),USE.NAMES=FALSE))
    trip.country=rbind(trip.country,data.frame(author.country=rep(dat.sub$author_country_1[1],nrow(temp1)),blogID=rep(bi,nrow(temp1)),
                               stay.in=temp1$Group.1,for.days=temp1$x+1,date.1st.arrival=temp2))
    
    for(bj in 1:nrow(dat.sub)){ 
      start=places[bj]
      end=places[bj+1]
      if(start!=end){
        x=match(start,rownames(mat.country)) #start country
        y=match(end,colnames(mat.country)) # end country
        mat.country[x,y]=mat.country[x,y]+1
      }
    }
  } else{
    print(paste(c(bi,unique(places)),collapse=","))
  }
}

## save results as RData, and output as a csv file
save(mat.country,trip.country,file="country matrix and stay duration.RData")
write.csv(mat.country,file="country matrix.csv")
write.csv(trip.country,file="country stay duration.csv",row.names=FALSE)

## selecte those countries that appear in at least 3 trip records and country name is not "unknown"
selected=which(colSums(mat.country)>2 & rowSums(mat.country)>2 & colnames(mat.country)!="unknown")
mat.country1=mat.country[selected,selected]
###

## detect country names that cannot match exactly with country-continent pairs
temp=lapply(colnames(mat.country1),grep,country.info$Country,value=TRUE)
temp1=lapply(colnames(mat.country1),grep,country.info$Country,value=FALSE)
matched=unlist(lapply(temp1,length))
which(matched!=1)
matched[matched!=1]

temp[[38]] #"India","British Indian Ocean Territory"
temp1[[38]]=106
temp[[80]] #"American Samoa","Samoa"
temp1[[80]]=245

unlist(lapply(temp1,length))
country_continent1=country.info$Continent[unlist(temp1)]
country_continent1[match(SEA,colnames(mat.country1))]=SEA
country_continent1[country_continent1=="Asia"]="Asia\\SEA"
table(country_continent1)
ctnts1=c(SEA,"Asia\\SEA",ctnts[-1])

save(mat.country1,file="country matrix_at least 3 trips.RData")
write.csv(mat.country1,file="country matrix_at least 3 trips.csv")
write.csv(cbind(SN=1:length(country_continent1),country=colnames(mat.country1),continent=country_continent1),
          file="country-continent pair_at least 3 trips.csv",row.names=FALSE)


### aggregate to larger scale
n=length(ctnts1)
mat.country2=matrix(0,nrow=n,ncol=n,dimnames=list(ctnts1,ctnts1))
for(i in 1:n) for(j in 1:n){
  from=which(country_continent1==ctnts1[i])
  to=which(country_continent1==ctnts1[j])
  mat.country2[i,j]=sum(mat.country1[from,to])
}

##################################################################################
##
##      extract inter-city/region trips and store them in a matrix
##          for cities within selected countries
##      extract the time people stay in a city/region
##
##################################################################################
for(i in c(4,8,11)){
  dat.temp=dat
  outside.country=which(!(dat$entry_country_1 %in% SEA[i]))
  dat.temp$entry_city_adm1[outside.country]="Other Countries"
  rnames=sort(unique(dat.temp$entry_city_adm1))
  mat.city=matrix(0,nrow=length(rnames),ncol=length(rnames),dimnames=list(rnames,rnames))
  trip.city=NULL
  ###
  for(bi in blogids){
    dat.sub=dat.temp[dat.temp$blogId==bi,]
    dat.sub=dat.sub[order(dat.sub$entry_date),]
    places=dat.sub$entry_city_adm1
    if(length(unique(places))>1){
      if(dat.sub$author_country_1[1]==SEA[i]){
        places=c(paste("Unknown Within",SEA[i]),places)
      } else{
        places=c("Other Countries",places)
      }
      temp=data.frame(stay.in=dat.sub$entry_city_adm1,for.days=c(as.numeric(diff(dat.sub$entry_date)),0))
      temp1=aggregate(temp$for.days,by=list(temp$stay.in),sum)
      temp2=to.date(sapply(temp1$Group.1,function(x) min(dat.sub$entry_date[dat.sub$entry_city_adm1==x]),USE.NAMES=FALSE))
      trip.city=rbind(trip.city,data.frame(author.country=rep(dat.sub$author_country_1[1],nrow(temp1)),blogID=rep(bi,nrow(temp1)),
                                                 stay.in=temp1$Group.1,for.days=temp1$x+1,date.1st.arrival=temp2))
      
      for(bj in 1:nrow(dat.sub)){
        start=places[bj]
        end=places[bj+1]
        if(start!=end){
          x=match(start,rownames(mat.city))
          y=match(end,colnames(mat.city))
          mat.city[x,y]=mat.city[x,y]+1
        }
      }
    } #else{
#       print(paste(c(bi,unique(places)),collapse=","))
#     }
  }
  save(mat.city,trip.city,file=paste(SEA[i],"city matrix and stay duration.RData"))
  write.csv(mat.city,file=paste(SEA[i],"city matrix.csv"))
  write.csv(trip.city,file=paste(SEA[i],"city stay duration.csv"),row.names=FALSE)
}
