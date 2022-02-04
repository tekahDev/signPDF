#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -a file to sign -b scaling -c position -d signature file -e page to sign"
   echo -e "\t-a /path/to/file/to/sign"
   echo -e "\t-b scaling for signature file (textwidth)"
   echo -e "\t-c absolute position for signature x,y (e.g. 14cm,8cm)"
   echo -e "\t-d /path/to/signature/file"
   echo -e "\t-e page to sign (only 1 possible)"
   echo -e "\t-f path to output file (optional, if not given output is ~/signPDF/signed.pdf)"
   echo ""
   echo "required packages: pdftk, texlive"
   echo ""
   echo "example:"
   echo -e "./signPDF.sh -a /home/user/Downloads/file_to_sign.pdf -b 0.4 -c 9cm,24.5cm -d /home/user/pictures/signature_file.png -e 1"
   exit 1 # Exit script after printing help
}

while getopts "a:b:c:d:e:f:" opt
do
   case "$opt" in
      a ) fileI="$OPTARG" ;;
      b ) scaling="$OPTARG" ;;
      c ) position="$OPTARG" ;;
      d ) fileS="$OPTARG" ;;
      d ) fileS="$OPTARG" ;;
      e ) page="$OPTARG" ;;
      f ) fileO="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$fileI" ] || [ -z "$scaling" ] || [ -z "$position" ] || [ -z "$fileS" ] || [ -z "$page" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct
if [ $fileS = "default" ]
then
    fileS="/home/thomas/signPDF/unterschrift.png"
fi

cp ~/signPDF/latex/signature_template.tex ~/signPDF/latex/signature.tex
sed -i 's/_scale_/'$scaling'/g' ~/signPDF/latex/signature.tex
sed -i 's+_file_+'$fileS'+g' ~/signPDF/latex/signature.tex
sed -i 's/_position_/'$position'/g' ~/signPDF/latex/signature.tex
cd ~/signPDF/latex
pdflatex signature.tex
cd ../

tmp=""

for (( i=1; i<=$page-1; i++ ))
do
    tmp+='files/blank.pdf '
done

pdftk $tmp ~/signPDF/latex/signature.pdf ~/signPDF/files/blank.pdf cat output ~/signPDF/files/tmp.pdf
pdftk $fileI multistamp ~/signPDF/files/tmp.pdf output ~/signPDF/files/signed.pdf

rm ~/signPDF/files/tmp.pdf
rm ~/signPDF/latex/signature.*

if [ -z "$fileO" ] 
then
    mv ~/signPDF/files/signed.pdf ~/signPDF/
else
    mv ~/signPDF/files/signed.pdf $fileO
fi
