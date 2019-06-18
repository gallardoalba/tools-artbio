if (length(commandArgs(TRUE)) == 0) {
  system("Rscript barplot.r -h", intern = F)
  q("no")
}


# load packages that are provided in the conda env
options( show.error.messages=F,
       error = function () { cat( geterrmessage(), file=stderr() ); q( "no", 1, F ) } )
loc <- Sys.setlocale("LC_MESSAGES", "en_US.UTF-8")
warnings()
library(optparse)
library(ggplot2)
library(ggrepel)


#Arguments
option_list = list(
  make_option(
    c("-i", "--input"),
    default = NA,
    type = 'character',
    help = "Input file that contains count data (no header)"
  ),
  make_option(
    c("-o", "--barplot"),
    default = NA,
    type = 'character',
    help = "PDF output file"
  )
)

opt = parse_args(OptionParser(option_list = option_list),
                 args = commandArgs(trailingOnly = TRUE))


## 
annotations = read.delim(opt$input, header=F)
colnames(annotations) = c("sample", "class", "percent_of_reads", "total")
annotations$percent=round(annotations$percent_of_reads/annotations$total*100, digits=2)
# ggplot2 plotting
ggtitle('Class proportions') 
ggplot(annotations, aes(x=total/2, y = percent_of_reads, fill = class, width = total)) +
       geom_bar(position="fill", stat="identity") + 
       facet_wrap(~sample, ncol=3 ) + geom_label_repel(aes(label = percent), position = position_fill(vjust = 0.5), size=2,show.legend = F) +
       coord_polar(theta="y") +
       labs(x = "Class fractions (%)") +
       theme(axis.text = element_blank(),
             axis.ticks = element_blank(),
             panel.grid  = element_blank(),
             axis.title.y = element_blank(),
             legend.position="bottom") +
       geom_text(aes(x = total/2, y= .5, label = paste(round(total/1000000, digits=3), "M"), vjust = 4, hjust=-1), size=2)
ggsave(file=opt$barplot, device="pdf")
