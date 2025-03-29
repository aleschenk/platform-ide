from langchain.llms import Ollama
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate
from datetime import datetime
import pytz

# Inicializar el modelo de Ollama
llm = Ollama(
    base_url='http://host.docker.internal:11434',
    model="qwen2.5-coder:latest"
)

# Crear un template que incluya el contexto del tiempo
template = """
Eres un asistente amigable que tiene conocimiento del tiempo actual.
La hora actual es: {current_time}

Pregunta del usuario: {question}

Por favor, responde de manera natural y amigable, incorporando el contexto del tiempo cuando sea relevante.
"""

# Crear el prompt template
prompt = PromptTemplate(
    input_variables=["current_time", "question"],
    template=template
)

# Crear la cadena de LangChain
chain = LLMChain(llm=llm, prompt=prompt)

def get_current_time():
    # Obtener la hora actual en la zona horaria local
    return datetime.now().strftime("%H:%M:%S")

def chat_with_time_context(question):
    current_time = get_current_time()
    response = chain.run(
        current_time=current_time,
        question=question
    )
    return response

# Ejemplo de uso
if __name__ == "__main__":
    # Ejemplo de preguntas
    questions = [
        "¿Qué hora es?",
        "¿Es hora de comer?",
        "¿Por qué el cielo es azul?"
    ]
    
    for question in questions:
        print(f"\nPregunta: {question}")
        print(f"Respuesta: {chat_with_time_context(question)}") 