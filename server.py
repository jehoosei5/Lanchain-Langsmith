import os
from langchain_groq import ChatGroq
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langserve import add_routes
from fastapi import FastAPI
from dotenv import load_dotenv

load_dotenv()

client = ChatGroq(
    api_key = os.getenv("GROQ_API_KEY"),
    model = "openai//gpt-oss-120b"
)

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "Translate the sentence to {language}"),
        ("user","{text}")
         ])

parser = StrOutputParser()

#create chain
chain = prompt | client | parser

app = FastAPI(
    title= "Lanchain server",
    version= "1.0",
    description= "A simple api server using langchain "
)

# adding chain routes
add_routes(
    app,
    chain,
    path="/chain"
)

if __name__=="__main__":
    import uvicorn
    uvicorn.run(app, host="localhost", port=8000)