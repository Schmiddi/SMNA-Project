#setwd("C:/Users/lilac/Google Drive/is4241/Project/Data")
library(ggmap)

##################################################################################
##
##      Load travelpod data and print some stats
##
##################################################################################
options(stringsAsFactors=FALSE)
dat=read.csv("data/travelpod.csv")
str(dat)

# Set date format
dat$entry_date=as.Date(dat$entry_date,format="%Y-%m-%d")
# Show overview of blog entry dates
summary(dat$entry_date)

##################################################################################
##
##      Correct the country names of the blog entries
##
##################################################################################
countries.raw=sort(unique(c(dat$author_country,dat$entry_country)))
countries=countries.raw
# Get all country names which contain any non alphabetic or whitespace character
unrecognized=!grepl("^[[:alpha:][:blank:]]*$", countries.raw)

# Create a vector countaining all countries, with bad names
idx=c(which(unrecognized),match(c("Birma","Burma","Republic of the Union of Myanm","Brunei Darussalam","Timor-Leste"),countries.raw))
cbind(idx,countries.raw=countries.raw[idx])
# Set new names for the selected countries
countries[idx]=c(rep("unknown",4),"Australia","Belgium","Indonesia","Indonesia","Cambodia","South Korea","Malaysia","Myanmar",
                 "Namibia","Northern Mariana Isl.","St. Maarten/St. Martin","Thailand","Timor-Leste","Zuid-Afrika",rep("Myanmar",3),"Brunei","East Timor")
cbind(idx,countries.raw=countries.raw[idx],countries=countries[idx])

# Get the countries with small typos
countries.match=lapply(countries,agrep,countries,value=TRUE)#http://stackoverflow.com/questions/6044112/r-how-to-measure-similarity-between-strings
nmatches=unlist(lapply(countries.match,length))
idx1=setdiff(which(nmatches>1),idx)
cbind(idx1,countries.raw[idx1])
countries[match(c("Autralia","Cambodja","Danmark","Malasia","Philippinen","Singapur","Tailandia","Tajlandia","Thailandia","Wietnam"),
                countries)]=c("Australia","Cambodia","Denmark","Malaysia","Philippines","Singapore",rep("Thailand",3),"Vietnam")
cbind(idx1,countries.raw[idx1],countries[idx1])

cbind(countries.raw,countries)
# Change the last still wrong country names
countries[match(c("Australien","Cambodge","Kambodscha","Filipijnen","Filippinerne","Indonesien","Republic of Indonesia","International",
                 "Korea Dem Peoples Rep","Lao Peoples Dem Rep","Nederland","Russian Federation","Spain and Canary Islands"),
                countries)]=c("Australia",rep("Cambodia",2),rep("Philippines",2),rep("Indonesia",2),"unknown","South Korea","Laos","Netherlands","Russia","Spain")

cbind(countries.raw,countries)
# Store all the indices of the corrected country names in corrected
corrected=which(countries.raw!=countries)
cbind(countries.raw,countries)[corrected,]

# Correct the country names for all blog entries
dat$author_country_1=dat$author_country
dat$entry_country_1=dat$entry_country
for(i in corrected){
  wh=which(dat$author_country_1 %in% countries.raw[i])
  dat$author_country_1[wh]=countries[i]
  
  wh=which(dat$entry_country_1 %in% countries.raw[i])
  dat$entry_country_1[wh]=countries[i]
}

##################################################################################
##
##      Match city names with geocodes to resolve bad city names
##      for Indonesia, Philippines, Vietman
##
##################################################################################
# Define the South-East-Asian countries
SEA=c("Brunei","Cambodia","East Timor","Indonesia","Laos","Malaysia","Myanmar","Philippines","Singapore","Thailand","Vietnam")
# SEA.code=c("BN","KH","TL","ID","LA","MY","MM","PH","SG","TH","VN")

dat$entry_city_adm1=NA
dat$entry_city_adm2=NA

for(i in c(4,8,11)){
  wh=which(dat$entry_country_1 %in% SEA[i])
#   cities.i=sort(unique(dat$entry_city[wh]))
#   city.country.i=paste(cities.i,SEA[i],sep=",")
#   gcode.output=geocode(city.country.i, source="google", output="more")
#   res=cbind(raw.city=cities.i,raw.country=rep(SEA[i],length(cities.i)),gcode.output)
#   save(res,file=paste(SEA[i],"cities Geocoding.RData"))
#   geocodeQueryCheck()#Google Geocoding API is subject to a query limit of 2,500 geolocation requests per day
  load(paste(SEA[i],"cities Geocoding.RData"))
  table(res$administrative_area_level_1)
  table(res$administrative_area_level_2)
  matched=match(dat$entry_city[wh],res$raw.city)
  dat$entry_city_adm1[wh]=res$administrative_area_level_1[matched]
  dat$entry_city_adm2[wh]=res$administrative_area_level_2[matched]
  dat$entry_city_adm1[wh][which(is.na(dat$entry_city_adm1[wh]))]=paste("Unknown Within",SEA[i])
  dat$entry_city_adm2[wh][which(is.na(dat$entry_city_adm2[wh]))]=paste("Unknown Within",SEA[i])
}


write.table(dat,file="data/travelpod corrected.csv",sep=",",row.names=FALSE)
save(dat,file="data/travelpod corrected.RData")

##################################################################################
##
##      Store the continent where each country belongs to
##
##################################################################################
countries.new=sort(unique(c(dat$author_country_1,dat$entry_country_1)))
country.info=read.csv("country codes from www.geonames.org.csv") ## NA for North America
str(country.info)
ctnts=c("Asia","Europe","Oceania","North America","Africa","South America","Antarctica")
country.info$Continent=ctnts[match(country.info$Continent,c("AS","EU","OC",NA,"AF","SA","AN"))]
