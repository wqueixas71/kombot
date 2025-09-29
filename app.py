import streamlit as st
import google.generativeai as genai
from datetime import datetime

# Configuração da API do Gemini usando Streamlit Secrets
genai.configure(api_key=st.secrets["gemini"]["api_key"])

# Configura o título e o ícone da página
st.set_page_config(
    page_title="Kombot",
    page_icon="🚴‍♀️",
    layout="centered"
)

st.title("🚴‍♀️ Olá! Bem-vindo(a) ao Kombot")
st.caption("Como podemos te ajudar hoje?")


def convert_messages_to_history(messages, max_history=50):
    """
    Converte o formato de mensagens do Streamlit para o formato de histórico do Gemini.
    O modelo Gemini espera uma lista de dicionários com 'role' e 'parts'.
    Limita o histórico para evitar contextos muito longos.
    """
    # Pega apenas as últimas N mensagens para não sobrecarregar o contexto
    recent_messages = messages[-max_history:] if len(messages) > max_history else messages
    
    history = []
    for message in recent_messages:
        role = "model" if message["role"] == "assistant" else "user"
        history.append({"role": role, "parts": [message["content"]]})
    return history


@st.cache_resource(show_spinner=False)
def get_model():
    """
    Inicializa e armazena o modelo do Gemini.
    """
    model = genai.GenerativeModel(
        model_name="gemini-2.5-flash",
        system_instruction=st.secrets["llm"]["system_instruction"]
    )
    return model


def count_tokens_estimate(messages):
    """
    Estimativa simples de tokens (aproximadamente 4 caracteres = 1 token).
    """
    total_chars = sum(len(msg["content"]) for msg in messages)
    return total_chars // 4


# Inicializa o estado da sessão
if "messages" not in st.session_state:
    st.session_state.messages = []

if "session_start" not in st.session_state:
    st.session_state.session_start = datetime.now()

# Sidebar com controles e estatísticas
with st.sidebar:
    st.header("⚙️ Controles")
    
    # Botão para limpar histórico
    if st.button("🗑️ Limpar Conversa", use_container_width=True):
        st.session_state.messages = []
        st.session_state.session_start = datetime.now()
        st.rerun()
    
    st.divider()
    
    # Estatísticas da conversa
    st.header("📊 Estatísticas")
    num_messages = len(st.session_state.messages)
    num_user = sum(1 for msg in st.session_state.messages if msg["role"] == "user")
    num_assistant = sum(1 for msg in st.session_state.messages if msg["role"] == "assistant")
    
    st.metric("Total de Mensagens", num_messages)
    col1, col2 = st.columns(2)
    with col1:
        st.metric("Suas", num_user)
    with col2:
        st.metric("Bot", num_assistant)
    
    # Estimativa de tokens
    if num_messages > 0:
        tokens_estimate = count_tokens_estimate(st.session_state.messages)
        st.metric("Tokens (aprox.)", f"{tokens_estimate:,}")
    
    # Tempo de sessão
    session_duration = datetime.now() - st.session_state.session_start
    minutes = int(session_duration.total_seconds() / 60)
    st.metric("Duração da Sessão", f"{minutes} min")
    
    st.divider()
    
    # Configurações
    st.header("🎛️ Configurações")
    use_streaming = st.checkbox("Resposta em tempo real", value=True)
    max_history = st.slider(
        "Máximo de mensagens no contexto",
        min_value=10,
        max_value=100,
        value=50,
        step=10,
        help="Limita quantas mensagens anteriores o bot considera"
    )

# Exibe o histórico de mensagens
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Campo de entrada do chat
if prompt := st.chat_input("Como podemos te ajudar?"):
    # Adiciona a mensagem do usuário ao histórico
    st.session_state.messages.append({"role": "user", "content": prompt})
    
    # Exibe a mensagem do usuário
    with st.chat_message("user"):
        st.markdown(prompt)

    # Gera e exibe a resposta do assistente
    with st.chat_message("assistant"):
        chat_model = get_model()
        
        # Converte apenas as mensagens anteriores (sem a última do usuário)
        history_for_gemini = convert_messages_to_history(
            st.session_state.messages[:-1],
            max_history=max_history
        )
        
        # Inicia a sessão de chat com o histórico
        chat_session = chat_model.start_chat(history=history_for_gemini)
        
        try:
            if use_streaming:
                # Resposta em streaming (tempo real)
                response_placeholder = st.empty()
                full_response = ""
                
                with st.spinner("Pensando..."):
                    response = chat_session.send_message(prompt, stream=True)
                    
                    for chunk in response:
                        if chunk.text:
                            full_response += chunk.text
                            response_placeholder.markdown(full_response + "▌")
                    
                    # Remove o cursor de digitação
                    response_placeholder.markdown(full_response)
                
                # Adiciona a resposta completa ao histórico
                st.session_state.messages.append({
                    "role": "assistant",
                    "content": full_response
                })
            else:
                # Resposta tradicional (tudo de uma vez)
                with st.spinner("Gerando resposta..."):
                    response = chat_session.send_message(prompt)
                    st.markdown(response.text)
                    
                    # Adiciona a resposta ao histórico
                    st.session_state.messages.append({
                        "role": "assistant",
                        "content": response.text
                    })
            
        except genai.types.generation_types.BlockedPromptException:
            st.warning(
                "⚠️ Desculpe, sua solicitação foi bloqueada por razões de segurança. "
                "Por favor, tente uma pergunta diferente."
            )
            # Remove a última mensagem do usuário
            st.session_state.messages.pop()
            
        except Exception as e:
            st.error(
                "❌ Ocorreu um erro ao processar sua mensagem. "
                "Por favor, tente novamente."
            )
            # Mostra detalhes do erro em modo expandido
            with st.expander("Ver detalhes do erro"):
                st.exception(e)
            # Remove a última mensagem do usuário
            st.session_state.messages.pop()

# Mensagem quando não há histórico
if len(st.session_state.messages) == 0:
    st.info("👋 Olá! Sou o Kombot. Faça sua primeira pergunta para começarmos nossa conversa!")