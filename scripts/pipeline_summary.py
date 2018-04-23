import json

out = {}

def addToDic(sample, lane, filename, path, md5):
    if lane == None:
        lane = "*"
    if not sample in out.keys():
        out[sample] = {}
    if lane != None:
        if not lane in out[sample].keys():
            out[sample][lane] = {}
    out[sample][lane][path] = {"filename": filename[:-4], "md5": md5}


for path in snakemake.input:
    if path[-4:] == ".md5":
        names = path.split("/")
        fileName = names[-1]
        if path[:3] == "QC_":
            if names[-2] == "metrics":
                lane = names[-3]
                sample = names[-4]
            else:
                lane = names[-2]
                sample = names[-3]
        else:
            lane = None
            sample =  names[-2]
        f = open(path, "r")
        md5 = f.read().split()[0]
        f.close()
        addToDic(sample, lane, fileName, path, md5)

outFile = open(snakemake.output[0], "w")
json.dump(out, outFile)
outFile.close()
