{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  black,
  datasets,
  # deepspeed,
  # evaluate,
  flake8,
  isort,
  numpy,
  packaging,
  parameterized,
  psutil,
  pytest,
  pytest-subtests,
  pytest-xdist,
  pyyaml,
  rich,
  sagemaker,
  scipy,
  scikit-learn,
  tensorboard,
  pytorch,
  tqdm,
  transformers,
  wandb,
}:
buildPythonPackage rec {
  pname = "accelerate";
  version = "0.12.0";
  src = fetchFromGitHub {
    owner = "huggingface";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-W0tFFX+ryHUK/hRHFXY3YfrHejfPwwk5xKomwSCJJvM=";
  };

  propagatedBuildInputs = [
    numpy
    packaging
    psutil
    pyyaml
    pytorch
  ];

  passthru.optional-dependencies = rec {
    quality = [
      black
      isort
      flake8
    ];
    test_prod = [
      pytest
      pytest-xdist
      pytest-subtests
      parameterized
    ];
    test_dev = [
      datasets
      # evaluate
      transformers
      scipy
      scikit-learn
      # deepspeed
      tqdm
    ];
    testing = test_prod ++ test_dev;
  };

  doCheck = false;

  pythonImportsCheck = ["accelerate"];

  meta = with lib; {
    homepage = "https://github.com/huggingface/accelerate";
    changelog = "https://github.com/huggingface/accelerate/releases/tag/v${version}";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [collinarnett];
  };
}
