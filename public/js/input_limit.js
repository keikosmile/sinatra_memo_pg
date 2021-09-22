const inputTitle = document.querySelector('.js-input-title');
const inputBody = document.querySelector('.js-input-body');

const enableButton = (isValidCount) => {
  const button = document.querySelector('.js-input-btn');
  if (isValidCount) {
    button.removeAttribute('disabled');
  } else {
    button.setAttribute('disabled', true);
  }
};

inputTitle.addEventListener('input', () => {
  const inputTitleCount = inputTitle.value.length;
  const inputBodyCount = inputBody.value.length;
  const isValidTitleCount = inputTitleCount > 0 && inputTitleCount < 30;
  const isValidBodyCount = inputBodyCount >= 0 && inputBodyCount < 500;
  enableButton(isValidTitleCount && isValidBodyCount);

  const countTitle = document.querySelector('.js-input-count-title');
  countTitle.innerText = inputTitleCount;

  const judgeTitle = document.querySelector('.js-input-judge-title');
  if (isValidTitleCount) {
    judgeTitle.classList.remove('-danger');
  } else {
    judgeTitle.classList.add('-danger');
  }
});

inputBody.addEventListener('input', () => {
  const inputTitleCount = inputTitle.value.length;
  const inputBodyCount = inputBody.value.length;
  const isValidTitleCount = inputTitleCount > 0 && inputTitleCount < 30;
  const isValidBodyCount = inputBodyCount >= 0 && inputBodyCount < 500;
  enableButton(isValidTitleCount && isValidBodyCount);

  const countBody = document.querySelector('.js-input-count-body');
  countBody.innerText = inputBodyCount;

  const judgeBody = document.querySelector('.js-input-judge-body');
  if (isValidBodyCount) {
    judgeBody.classList.remove('-danger');
  } else {
    judgeBody.classList.add('-danger');
  }
});

const evt = new Event('input');
inputTitle.dispatchEvent(evt);
inputBody.dispatchEvent(evt);
