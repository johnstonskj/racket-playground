import heapq

class streamMedian:
    def __init__(self):
        self.minHeap, self.maxHeap = [], []
        self.N=0
 
    def insert(self, num):
        if self.N%2==0:
            heapq.heappush(self.maxHeap, -1*num)
            self.N+=1
            if len(self.minHeap)==0:
                return
            if -1*self.maxHeap[0]>self.minHeap[0]:
                toMin=-1*heapq.heappop(self.maxHeap)
                toMax=heapq.heappop(self.minHeap)
                heapq.heappush(self.maxHeap, -1*toMax)
                heapq.heappush(self.minHeap, toMin)
        else:
            toMin=-1*heapq.heappushpop(self.maxHeap, -1*num)
            heapq.heappush(self.minHeap, toMin)
            self.N+=1
 
    def getMedian(self):
        if self.N%2==0:
            return (-1*self.maxHeap[0]+self.minHeap[0])/2.0
        else:
            return -1*self.maxHeap[0]


data = [36,43,14,21,13,45,47,28,19,47,2,14,38,25,50,43,46,41,37,42,21,37,41,0,6,5,7,38,28,18,28,47,27,38,13,48,
24,43,7,18,24,42,32,4,11,7,41,42,38,50,32,48,45,9,36,7,44,32,49,18,45,49,19,28,13,41,27,25,17,11,15,10,
4,32,34,47,34,21,14,49,6,13,30,48,42,29,8,6,39,39,28,3,36,31,47,30,3,25,0,17]

calc = streamMedian()

for i in data:
    calc.insert(i)

print(calc.getMedian())
